#include "../lib/kt.h"

#define GEO_Y0 16807L
#define GEO_X0 48271L
#define MODULO 20183

#define QUEUE_CAP 2048
#define CAVE_EXP 16

#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define ABS(a) ((a) < 0 ? -(a) : (a))

typedef enum {
    dir_up,
    dir_right,
    dir_down,
    dir_left,
} dir_t;

typedef enum {
    region_rocky,
    region_wet,
    region_narrow,
} region_type_t;

typedef enum {
    tool_none,
    tool_torch,
    tool_gear,
} tool_t;

typedef struct {
    b8 inited;
    i32 x, y;
    i32 took[3];
    i32 erosion_level;
    region_type_t type;
} region_t;

typedef struct {
    region_t* regions;
    i32 len;
    i32 target_x, target_y;
    i32 depth;
} cave_t;

typedef struct {
    i32 x, y;
    i32 took;
    tool_t tool;
} pos_t;

typedef struct {
    pos_t next;
    b8 reachable;
} pos_go_t;

typedef struct {
    i32 head, tail;
    i32 len, cap;
    pos_t* arr;
} queue_t;

static region_t* cave_get(cave_t* c, i32 x, i32 y);

static pos_go_t pos_go(pos_t p, cave_t* c, dir_t d)
{
    i32 dx = 0, dy = 0;
    switch (d) {
        case dir_up:
            dy = -1;
            break;
        case dir_right:
            dx = 1;
            break;
        case dir_down:
            dy = 1;
            break;
        case dir_left:
            dx = -1;
            break;
    }

    pos_go_t g = {0};

    region_t* r = cave_get(c, p.x + dx, p.y + dy);
    if (!r) return g;

    if (p.tool == tool_none && r->type == region_rocky) {
        return g;
    } else if (p.tool == tool_torch && r->type == region_wet) {
        return g;
    } else if (p.tool == tool_gear && r->type == region_narrow) {
        return g;
    }

    // reachable
    p.took += 1;
    p.x += dx;
    p.y += dy;
    g.next = p;
    g.reachable = TRUE;
    return g;
}

static pos_t pos_change_tool(pos_t p, region_t* r)
{
    switch (r->type) {
        case region_rocky:
            ASSERT_MSG(p.tool != tool_none,  //
                       "wrong tool at rocky (%d,%d)", p.x, p.y);
            p.tool = p.tool == tool_gear ? tool_torch : tool_gear;
            break;
        case region_wet:
            ASSERT_MSG(p.tool != tool_torch,  //
                       "wrong tool at wet (%d,%d)", p.x, p.y);
            p.tool = p.tool == tool_gear ? tool_none : tool_gear;
            break;
        case region_narrow:
            ASSERT_MSG(p.tool != tool_gear,  //
                       "wrong tool at narrow (%d,%d)", p.x, p.y);
            p.tool = p.tool == tool_torch ? tool_none : tool_torch;
            break;
        default:
            ASSERT_MSG(0,  //
                       "unknown region type %d at (%d,%d)", r->type, p.x, p.y);
    }
    p.took += 7;
    return p;
}

static queue_t queue_init(void* arena)
{
    queue_t q;
    q.head = 0;
    q.tail = 0;
    q.len = 0;
    q.cap = QUEUE_CAP;
    q.arr = kt_linear_arena_array_zero(arena, pos_t, QUEUE_CAP);
    return q;
}

static i32 queue_len(queue_t* q) { return q->len; }

static void queue_in(queue_t* q, pos_t p)
{
    ASSERT_MSG(q->len < q->cap, "queue overflow %d", q->len);

    q->arr[q->tail] = p;
    q->tail = (q->tail + 1) % q->cap;
    q->len += 1;
}

static pos_t queue_out(queue_t* q)
{
    ASSERT_MSG(q->len > 0, "queue underflow %d", q->len);

    i32 min = q->arr[q->head].took;
    i32 m_i = 0;
    for (i32 i = 1; i < q->len; i++) {
        i32 idx = (q->head + i) % q->cap;
        if (q->arr[idx].took < min) {
            min = q->arr[idx].took;
            m_i = i;
        }
    }

    if (m_i != 0) {
        i32 i = (q->head + m_i) % q->cap;
        pos_t temp = q->arr[i];
        q->arr[i] = q->arr[q->head];
        q->arr[q->head] = temp;
    }

    pos_t v = q->arr[q->head];
    q->head = (q->head + 1) % q->cap;
    q->len -= 1;
    return v;
}

static u64 hash_djb2(i32 x, i32 y)
{
    u64 hash = 5381;
    hash = ((hash << 5) + hash) + x; /* hash * 33 + x */
    hash = ((hash << 5) + hash) + y; /* hash * 33 + y */
    return hash;
}

static cave_t cave_init(void* arena, i32 target_x, i32 target_y, i32 depth)
{
    cave_t c;
    c.regions = kt_linear_arena_array_zero(arena, region_t, 1 << CAVE_EXP);
    c.len = 0;
    c.target_x = target_x;
    c.target_y = target_y;
    c.depth = depth;
    return c;
}

static i32 cave_erosion_level(cave_t* c, i32 x, i32 y)
{
    i64 geo = 0;
    if (x == 0 && y == 0) {
        geo = 0;
    } else if (x == c->target_x && y == c->target_y) {
        geo = 0;
    } else if (y == 0) {
        geo = x * GEO_Y0;
    } else if (x == 0) {
        geo = y * GEO_X0;
    } else {
        region_t* r1 = cave_get(c, x - 1, y);
        region_t* r2 = cave_get(c, x, y - 1);
        geo = r1->erosion_level * r2->erosion_level;
    }
    return (geo + (i64)c->depth) % MODULO;
}

static region_t* cave_get(cave_t* c, i32 x, i32 y)
{
    if (x < 0 || y < 0) return 0;

    u64 hash = hash_djb2(x, y);
    i32 mask = (1 << CAVE_EXP) - 1;
    i32 step = (hash >> (28 - CAVE_EXP)) | 1;

    for (u64 i = hash;;) {
        i = (i + step) % mask;
        region_t* r = c->regions + i;
        if (!r->inited) {
            r->inited = TRUE;
            r->x = x;
            r->y = y;
            r->took[0] = 2147483647;
            r->took[1] = 2147483647;
            r->took[2] = 2147483647;
            r->erosion_level = cave_erosion_level(c, x, y);
            r->type = r->erosion_level % 3;
            c->len += 1;
            return r;
        }
        if (r->x == x && r->y == y) {
            return r;
        }
        ASSERT_MSG(c->len < mask,  //
                   "cave overflow, len %d, cap %d", c->len, mask);
    }
}

static region_t* cave_target(cave_t* c)
{
    return cave_get(c, c->target_x, c->target_y);
}

static i32 risk_level_impl(void* arena, i32 target_x, i32 target_y, i32 depth)
{
    cave_t c = cave_init(arena, target_x, target_y, depth);

    i32 risk_lv = 0;
    for (i32 y = 0; y <= target_y; y++) {
        for (i32 x = 0; x <= target_x; x++) {
            region_t* r = cave_get(&c, x, y);
            risk_lv += r->type;
        }
    }

    return risk_lv;
}

static void cave_estimate(cave_t* c)
{
    pos_t p = {.x = 0, .y = 0, .took = 0, .tool = tool_torch};
    for (; p.x != c->target_x;) {
        pos_go_t pp = pos_go(p, c, dir_right);
        if (!pp.reachable) {
            p = pos_change_tool(p, cave_get(c, p.x, p.y));
        } else {
            p = pp.next;
        }
    }

    for (; p.y != c->target_y;) {
        pos_go_t pp = pos_go(p, c, dir_down);
        if (!pp.reachable) {
            p = pos_change_tool(p, cave_get(c, p.x, p.y));
        } else {
            p = pp.next;
        }
    }

    if (p.tool == tool_torch) {
        cave_target(c)->took[tool_torch] = p.took;
    } else {
        cave_target(c)->took[tool_torch] = p.took + 7;
    }
}

static i32 reach_target_impl(void* arena, i32 target_x, i32 target_y, i32 depth)
{
    dir_t dirs[] = {dir_right, dir_down, dir_left, dir_up};

    queue_t q = queue_init(arena);
    pos_t p = {.x = 0, .y = 0, .took = 0, .tool = tool_torch};
    queue_in(&q, p);

    cave_t c = cave_init(arena, target_x, target_y, depth);
    cave_get(&c, 0, 0)->took[tool_torch] = 0;

    cave_estimate(&c);

    while (queue_len(&q) > 0) {
        pos_t p = queue_out(&q);
        region_t* r = cave_get(&c, p.x, p.y);

        if (p.x > target_x * 5 || p.took > r->took[p.tool] ||
            (p.took + ABS(p.x - target_x) + ABS(p.y - target_y)) >=
                cave_target(&c)->took[tool_torch]) {
            continue;
        }

        pos_t ps[] = {p, pos_change_tool(p, r)};
        for (i32 j = 0; j < 2; j++) {
            pos_t pp = ps[j];
            for (i32 i = 0; i < 4; i++) {
                pos_go_t np = pos_go(pp, &c, dirs[i]);
                if (!np.reachable) continue;
                region_t* nr = cave_get(&c, np.next.x, np.next.y);
                if (nr->took[np.next.tool] > np.next.took) {
                    nr->took[np.next.tool] = np.next.took;
                    queue_in(&q, np.next);
                }
            }
        }
    }

    i32* tooks = cave_target(&c)->took;
    i32 v1 = MIN(tooks[tool_none], tooks[tool_gear]) + 7;
    return MIN(v1, tooks[tool_torch]);
}

i32 risk_level(const char* input_file)
{
    UNUSED(input_file);
    void* arena = kt_linear_arena_init(4 * 1024 * 1024);
    i32 result = risk_level_impl(arena, 15, 700, 4848);
    kt_linear_arena_deinit(arena);
    return result;
}

i32 reach_target(const char* input_file)
{
    UNUSED(input_file);
    void* arena = kt_linear_arena_init(4 * 1024 * 1024);
    i32 result = reach_target_impl(arena, 15, 700, 4848);
    kt_linear_arena_deinit(arena);
    return result;
}

#include "../lib/kt.h"

#define HM_EXP 14
#define HM_CAP 16384
#define HEAD_CAP 64
#define STACK_CAP 1024
#define QUEUE_CAP 1024
#define BRACH_CAP 4

typedef enum {
    dir_north,
    dir_east,
    dir_south,
    dir_west,
} dir_t;

typedef struct {
    i32 x, y;
    b8 is_head;
    b8 doors[4];  // true -> door, false -> wall
    b8 visited;
    i32 dist;
} room_t;

typedef struct {
    b8* occupies;
    room_t* vals;
    i32 len;
} hm_t;

typedef struct {
    i32 len;
    i32 arr[STACK_CAP];
} stack_t;

typedef struct {
    i32 arr[BRACH_CAP];
    i32 len;
    i32 closing_at;
} branch_t;

typedef struct {
    i32 head, tail, len;
    room_t* arr[QUEUE_CAP];
} queue_t;

static i32 queue_len(queue_t* q) { return q->len; }

static void queue_in(queue_t* q, room_t* r)
{
    ASSERT_MSG(q->len < QUEUE_CAP, "queue overflow %d", q->len);
    q->arr[q->tail] = r;
    q->tail = (q->tail + 1) % QUEUE_CAP;
    q->len += 1;
}

static room_t* queue_out(queue_t* q)
{
    ASSERT_MSG(q->len > 0, "queue underflow %d", q->len);
    room_t* v = q->arr[q->head];
    q->head = (q->head + 1) % QUEUE_CAP;
    q->len -= 1;
    return v;
}

static void branch_add(branch_t* b, i32 v)
{
    ASSERT_MSG(b->len < BRACH_CAP, "branch overflow %d", b->len);
    b->arr[b->len] = v;
    b->len += 1;
}

static void branch_close_at(branch_t* b, i32 v) { b->closing_at = v; }

static void stack_push(stack_t* s, i32 v)
{
    ASSERT_MSG(s->len < STACK_CAP, "stack overflow %d", s->len);
    s->arr[s->len] = v;
    s->len += 1;
}

static i32 stack_peek(stack_t* s)
{
    ASSERT_MSG(s->len > 0, "stack empty %d", s->len);
    return s->arr[s->len - 1];
}

static i32 stack_pop(stack_t* s)
{
    ASSERT_MSG(s->len > 0, "stack empty %d", s->len);
    s->len -= 1;
    return s->arr[s->len];
}

static u64 hash_djb2(i32 x, i32 y)
{
    u64 hash = 5381;
    hash = ((hash << 5) + hash) + x; /* hash * 33 + x */
    hash = ((hash << 5) + hash) + y; /* hash * 33 + y */
    return hash;
}

/*
static void hm_print(hm_t* m)
{
    for (i32 i = 0; i < HM_CAP; i++) {
        if (m->occupies[i]) {
            room_t r = m->vals[i];
            printf("room (%d,%d), visited %d, dist %d\n",  //
                   r.x, r.y, r.visited, r.dist);
            printf("#%c#\n", r.doors[dir_north] ? '-' : '#');
            printf("%c.%c\n",  //
                   r.doors[dir_west] ? '|' : '#',
                   r.doors[dir_east] ? '|' : '#');
            printf("#%c#\n", r.doors[dir_south] ? '-' : '#');
        }
    }
    printf("hm total rooms: %d\n", m->len);
}
*/

static hm_t* hm_init()
{
    hm_t* m = kt_malloc(sizeof(hm_t));
    m->occupies = kt_malloc(sizeof(b8) * HM_CAP);
    memset(m->occupies, 0, sizeof(b8) * HM_CAP);
    m->vals = kt_malloc(sizeof(room_t) * HM_CAP);
    memset(m->vals, 0, sizeof(room_t) * HM_CAP);
    m->len = 0;
    return m;
}

static void hm_deinit(hm_t* m)
{
    free(m->occupies);
    free(m->vals);
    free(m);
}

static room_t* hm_get(hm_t* m, i32 x, i32 y)
{
    u64 hash = hash_djb2(x, y);
    i32 step = (hash >> (28 - HM_EXP)) | 1;

    for (u64 i = hash;;) {
        i = (i + step) % HM_CAP;
        b8 occupied = m->occupies[i];
        if (!occupied) {
            m->occupies[i] = TRUE;
            m->vals[i].x = x;
            m->vals[i].y = y;
            m->len += 1;
            return m->vals + i;
        }
        if (m->vals[i].x == x && m->vals[i].y == y) {
            return m->vals + i;
        }
        ASSERT_MSG(m->len < HM_CAP,  //
                   "hm overflow, len %d, cap %d", m->len, HM_CAP);
    }
}

static void hm_reset(hm_t* dst, hm_t* src)
{
    memcpy(dst->occupies, src->occupies, sizeof(b8) * HM_CAP);
    memcpy(dst->vals, src->vals, sizeof(room_t) * HM_CAP);
    dst->len = src->len;
}

static void hm_merge(hm_t* dst, hm_t* src)
{
    for (i32 i = 0; i < HM_CAP; i++) {
        if (src->occupies[i]) {
            room_t r = src->vals[i];
            room_t* d = hm_get(dst, r.x, r.y);
            d->is_head |= r.is_head;
            for (i32 j = 0; j < 4; j++) {
                d->doors[j] |= r.doors[j];
            }
        }
    }
}

static dir_t dir_from(char c)
{
    switch (c) {
        case 'N':
            return dir_north;
        case 'E':
            return dir_east;
        case 'S':
            return dir_south;
        case 'W':
            return dir_west;
        default:
            ASSERT_MSG(0, "unknown step %c", c);
    }
}

static void dir_update(dir_t dir, i32* dx, i32* dy)
{
    switch (dir) {
        case dir_north:
            *dx = 0;
            *dy = 1;
            break;
        case dir_east:
            *dx = 1;
            *dy = 0;
            break;
        case dir_south:
            *dx = 0;
            *dy = -1;
            break;
        case dir_west:
            *dx = -1;
            *dy = 0;
            break;
    }
}

static room_t* room_go(room_t* from, hm_t* m, dir_t dir)
{
    i32 dx = 0;
    i32 dy = 0;
    dir_update(dir, &dx, &dy);

    return hm_get(m, from->x + dx, from->y + dy);
}

static room_t* room_next(room_t* from, hm_t* m, dir_t dir)
{
    room_t* next = room_go(from, m, dir);
    switch (dir) {
        case dir_north:
            from->doors[dir_north] = TRUE;
            next->doors[dir_south] = TRUE;
            break;
        case dir_east:
            from->doors[dir_east] = TRUE;
            next->doors[dir_west] = TRUE;
            break;
        case dir_south:
            from->doors[dir_south] = TRUE;
            next->doors[dir_north] = TRUE;
            break;
        case dir_west:
            from->doors[dir_west] = TRUE;
            next->doors[dir_east] = TRUE;
            break;
    }
    return next;
}

static branch_t* facility_build_branch(void* arena, const char* route)
{
    stack_t stack = {0};
    i32 len = strlen(route);
    branch_t* bs = kt_linear_arena_array_zero(arena, branch_t, len);

    for (i32 idx = 0;; idx++) {
        const char c = route[idx];
        if (c == '$') {
            break;
        } else if (c == '(') {
            stack_push(&stack, idx);
            branch_add(bs + idx, idx + 1);
        } else if (c == '|') {
            i32 p = stack_peek(&stack);
            branch_add(bs + p, idx + 1);
        } else if (c == ')') {
            i32 p = stack_pop(&stack);
            branch_close_at(bs + p, idx);
        }
    }

    return bs;
}

static void facility_walk_update(hm_t* m, dir_t dir)
{
    i32 mark[HEAD_CAP] = {0};
    i32 len = 0;
    for (i32 i = 0; i < HM_CAP; i++) {
        if (m->occupies[i] && m->vals[i].is_head) {
            ASSERT_MSG(len < HEAD_CAP, "update mark overflow %d", len);
            mark[len++] = i;
        }
    }
    for (i32 j = 0; j < len; j++) {
        i32 i = mark[j];
        room_t* next = room_next(m->vals + i, m, dir);
        m->vals[i].is_head = FALSE;
        next->is_head = TRUE;
    }
}

static hm_t* facility_walk(hm_t* m,                     //
                           const char* route, i32 idx,  //
                           branch_t* branches)          //
{
    for (;;) {
        const char c = route[idx];

        if (c == '^') {
            idx += 1;
        } else if (c == '$') {
            return m;
        } else if (c == '(') {
            branch_t b = branches[idx];
            hm_t* copy = hm_init();
            hm_t* merged = hm_init();
            for (i32 i = 0; i < b.len; i++) {
                i32 j = b.arr[i];
                hm_reset(copy, m);
                copy = facility_walk(copy, route, j, branches);
                hm_merge(merged, copy);
            }
            idx = b.closing_at + 1;
            hm_deinit(m);
            hm_deinit(copy);
            m = merged;
        } else if (c == '|') {
            return m;
        } else if (c == ')') {
            return m;
        } else {
            facility_walk_update(m, dir_from(c));
            idx++;
        }
    }
}

static hm_t* facility_init(const char* route)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    branch_t* bs = facility_build_branch(arena, route);
    hm_t* m = hm_init();
    hm_get(m, 0, 0)->is_head = TRUE;

    m = facility_walk(m, route, 0, bs);

    kt_linear_arena_deinit(arena);

    return m;
}

static void facility_reach(hm_t* m)
{
    dir_t dirs[4] = {dir_north, dir_east, dir_south, dir_west};
    queue_t q = {0};
    room_t* start = hm_get(m, 0, 0);
    start->visited = TRUE;
    queue_in(&q, start);

    for (; queue_len(&q) > 0;) {
        i32 size = queue_len(&q);
        for (i32 i = 0; i < size; i++) {
            room_t* curr = queue_out(&q);
            for (i32 j = 0; j < 4; j++) {
                dir_t dir = dirs[j];
                if (!curr->doors[dir]) continue;
                room_t* next = room_go(curr, m, dir);
                if (next->visited) continue;
                next->visited = TRUE;
                next->dist = curr->dist + 1;
                queue_in(&q, next);
            }
        }
    }
}

static i32 facility_furthest(hm_t* m)
{
    i32 max = 0;
    for (i32 i = 0; i < HM_CAP; i++) {
        if (m->occupies[i]) {
            room_t r = m->vals[i];
            if (r.dist > max) {
                max = r.dist;
            }
        }
    }
    return max;
}

static i32 facility_path_at_least(hm_t* m, i32 v)
{
    i32 count = 0;
    for (i32 i = 0; i < HM_CAP; i++) {
        if (m->occupies[i]) {
            room_t r = m->vals[i];
            if (r.dist >= v) {
                count += 1;
            }
        }
    }
    return count;
}

static i32 path_at_least_impl(const char* route)
{
    hm_t* facility = facility_init(route);
    facility_reach(facility);
    i32 result = facility_path_at_least(facility, 1000);
    hm_deinit(facility);
    return result;
}

static i32 furthest_room_impl(const char* route)
{
    hm_t* facility = facility_init(route);
    facility_reach(facility);
    i32 result = facility_furthest(facility);
    hm_deinit(facility);
    return result;
}

i32 furthest_room(const char* input_file)
{
    char* route = kt_read_all(input_file);
    i32 result = furthest_room_impl(route);
    free((void*)route);
    return result;
}

i32 path_at_least(const char* input_file)
{
    char* route = kt_read_all(input_file);
    i32 result = path_at_least_impl(route);
    free((void*)route);
    return result;
}

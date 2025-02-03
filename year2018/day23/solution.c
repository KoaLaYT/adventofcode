#include "../lib/kt.h"
#include "../lib/re.h"

#define QUEUE_CAP 2048

#define ABS(a) ((a) < 0 ? -(a) : (a))
#define MIN(a, b) ((a < b) ? (a) : (b))
#define MAX(a, b) ((a > b) ? (a) : (b))

typedef struct {
    i32 x, y, z;
    i32 r;
    i32 count;
} nanobot_t;

typedef struct {
    i32 head, tail;
    i32 len;
    nanobot_t arr[QUEUE_CAP];
} queue_t;

typedef struct {
    nanobot_t* bots;
    i32 len;
} context_t;

static nanobot_t nanobot_from(const char* s)
{
    re_t pattern = re_compile("-?\\d+");
    i32 len;

    i32 vs[4];

    for (i32 i = 0; i < 4; i++) {
        s += re_matchp(pattern, s, &len);
        vs[i] = kt_atoi_s(s, len);
        s += len;
    }

    nanobot_t b = {0};
    b.x = vs[0];
    b.y = vs[1];
    b.z = vs[2];
    b.r = vs[3];
    return b;
}

static context_t context_init(void* arena, const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);
    const char* line;
    i32 len = 0;

    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        len += 1;
    }
    kt_scanner_reset(scanner);

    nanobot_t* bots = kt_linear_arena_array_zero(arena, nanobot_t, len);
    len = 0;

    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        bots[len++] = nanobot_from(line);
    }
    kt_scanner_deinit(scanner);

    context_t ctx;
    ctx.bots = bots;
    ctx.len = len;
    return ctx;
}

static i32 nanobot_distance(nanobot_t self, nanobot_t other)
{
    return ABS(self.x - other.x) +  //
           ABS(self.y - other.y) +  //
           ABS(self.z - other.z);
}

static i32 nanobot_distance_zero(nanobot_t self)
{
    return ABS(self.x) + ABS(self.y) + ABS(self.z);
}

static void queue_in(queue_t* q, nanobot_t b)
{
    ASSERT_MSG(q->len < QUEUE_CAP, "queue overflow %d", q->len);

    q->arr[q->tail] = b;
    q->tail = (q->tail + 1) % QUEUE_CAP;
    q->len += 1;
}

static nanobot_t queue_out(queue_t* q)
{
    ASSERT_MSG(q->len > 0, "queue underflow %d", q->len);

    // search priority
    // 1. max count
    // 2. min r
    // 3. closer to (0,0,0)
    nanobot_t h = q->arr[q->head];
    i32 max_count = h.count;
    i32 min_r = h.r;
    i32 zero_d = nanobot_distance_zero(h) - h.r;
    i32 m_i = 0;

    for (i32 i = 1; i < q->len; i++) {
        i32 idx = (q->head + i) % QUEUE_CAP;
        nanobot_t b = q->arr[idx];
        if (b.count < max_count) continue;
        if (b.count > max_count) {
            max_count = b.count;
            min_r = b.r;
            zero_d = nanobot_distance_zero(b) - b.r;
            m_i = i;
            continue;
        }
        // tie count
        if (b.r > min_r) continue;
        if (b.r < min_r) {
            min_r = b.r;
            zero_d = nanobot_distance_zero(b) - b.r;
            m_i = i;
            continue;
        }
        // tie count & r
        i32 b_zero_d = nanobot_distance_zero(b) - b.r;
        if (b_zero_d < zero_d) {
            zero_d = b_zero_d;
            m_i = i;
        }
    }

    if (m_i != 0) {
        i32 i = (q->head + m_i) % QUEUE_CAP;
        nanobot_t temp = q->arr[i];
        q->arr[i] = q->arr[q->head];
        q->arr[q->head] = temp;
    }

    nanobot_t v = q->arr[q->head];
    q->head = (q->head + 1) % QUEUE_CAP;
    q->len -= 1;
    return v;
}

static i32 nanobot_count_intersects(nanobot_t* bots, i32 len, nanobot_t box)
{
    i32 count = 0;
    for (i32 i = 0; i < len; i++) {
        nanobot_t bot = bots[i];
        if (nanobot_distance(bot, box) <= bot.r + box.r) {
            count += 1;
        }
    }
    return count;
}

static i32 in_range_impl(context_t ctx)
{
    i32 max_i = 0;
    i32 max_r = ctx.bots[0].r;

    for (i32 i = 1; i < ctx.len; i++) {
        if (ctx.bots[i].r > max_r) {
            max_r = ctx.bots[i].r;
            max_i = i;
        }
    }

    nanobot_t largest = ctx.bots[max_i];
    i32 count = 0;
    for (i32 i = 0; i < ctx.len; i++) {
        nanobot_t other = ctx.bots[i];
        if (nanobot_distance(largest, other) <= largest.r) {
            count += 1;
        }
    }
    return count;
}

static i32 largest_in_range_impl(context_t ctx)
{
    i32 maxp = 0;

    for (i32 i = 0; i < ctx.len; i++) {
        nanobot_t bot = ctx.bots[i];
        maxp = MAX(maxp, ABS(bot.x));
        maxp = MAX(maxp, ABS(bot.y));
        maxp = MAX(maxp, ABS(bot.z));
    }

    i32 init_r = 1;
    while (init_r < 3 * maxp) init_r *= 2;

    queue_t q = {0};
    queue_in(&q, (nanobot_t){0, 0, 0, init_r, ctx.len});

    for (;;) {
        nanobot_t box = queue_out(&q);
        if (box.r == 0) {
            return nanobot_distance_zero(box);
        }

        i32 r = box.r / 2;
        if (r == 0) {
            nanobot_t nb = {box.x, box.y, box.z, r, 0};
            nb.count = nanobot_count_intersects(ctx.bots, ctx.len, nb);
            queue_in(&q, nb);
            continue;
        }
        for (i32 x = -r; x <= r; x += r) {
            for (i32 y = -r; y <= r; y += r) {
                for (i32 z = -r; z <= r; z += r) {
                    nanobot_t nb = {box.x + x, box.y + y, box.z + z, r, 0};
                    nb.count = nanobot_count_intersects(ctx.bots, ctx.len, nb);
                    queue_in(&q, nb);
                }
            }
        }
    }
}

i32 in_range(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    context_t ctx = context_init(arena, input_file);
    i32 result = in_range_impl(ctx);
    kt_linear_arena_deinit(arena);
    return result;
}

i32 largest_in_range(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    context_t ctx = context_init(arena, input_file);
    i32 result = largest_in_range_impl(ctx);
    kt_linear_arena_deinit(arena);
    return result;
}

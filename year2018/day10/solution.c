#include "../lib/kt.h"
#include "../lib/re.h"

#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

typedef struct {
    int x, y;
    int vx, vy;
} point_t;

typedef struct {
    int min_x, min_y;
    int max_x, max_y;
} region_t;

typedef struct {
    point_t* ps;
    int len;
} context_t;

static void point_from(const char* s, point_t* p)
{
    re_t pattern = re_compile("-?\\d+");
    int len;

    s += re_matchp(pattern, s, &len);
    p->x = kt_atoi_s(s, len);
    s += len;

    s += re_matchp(pattern, s, &len);
    p->y = kt_atoi_s(s, len);
    s += len;

    s += re_matchp(pattern, s, &len);
    p->vx = kt_atoi_s(s, len);
    s += len;

    s += re_matchp(pattern, s, &len);
    p->vy = kt_atoi_s(s, len);
    s += len;

    assert(s[0] == '>');
}

static region_t next_tick(point_t* ps, int len)
{
    int min_x = 2147483647, min_y = 2147483647;
    int max_x = -2147483647, max_y = -2147483647;

    for (int i = 0; i < len; i++) {
        ps[i].x += ps[i].vx;
        ps[i].y += ps[i].vy;

        min_x = MIN(min_x, ps[i].x);
        max_x = MAX(max_x, ps[i].x);
        min_y = MIN(min_y, ps[i].y);
        max_y = MAX(max_y, ps[i].y);
    }

    region_t r;
    r.min_x = min_x;
    r.max_x = max_x;
    r.min_y = min_y;
    r.max_y = max_y;
    return r;
}

static int region_height(region_t r) { return r.max_y - r.min_y; }

static int has_point(point_t* ps, int len, int x, int y)
{
    for (int i = 0; i < len; i++) {
        if (ps[i].x == x && ps[i].y == y) {
            return 1;
        }
    }
    return 0;
}

static const char* show_message(void* arena, point_t* ps, int len, region_t r)
{
    int width = r.max_x - r.min_x + 1;  // plus '\n'
    int height = r.max_y - r.min_y;
    char* out = kt_linear_arena_array_zero(arena, char, width* height);

    int i = 0;
    for (int y = r.min_y; y <= r.max_y; y++) {
        for (int x = r.min_x; x <= r.max_x; x++) {
            out[i++] = has_point(ps, len, x, y) ? '#' : '.';
        }
        out[i++] = '\n';
    }

    return out;
}

static int wait_seconds_impl(void* arena, point_t* ps, int len)
{
    point_t* copy = kt_linear_arena_array(arena, point_t, len);
    memcpy(copy, ps, sizeof(point_t) * len);

    int min_tick = 0;
    int min_height = 2147483647;
    for (int tick = 0; tick < 11000; tick++) {
        region_t r = next_tick(copy, len);
        int height = region_height(r);
        if (height < min_height) {
            min_height = height;
            min_tick = tick;
        }
    }

    return min_tick;
}

static const char* guess_message_impl(void* arena, point_t* ps, int len)
{
    int wait = wait_seconds_impl(arena, ps, len);

    region_t r;
    for (int i = 0; i <= wait; i++) {
        r = next_tick(ps, len);
    }
    const char* msg = show_message(arena, ps, len, r);

    char* out = kt_malloc(strlen(msg) + 2);
    out[0] = '\n';
    strcpy(out + 1, msg);

    return out;
}

static context_t context_init(void* arena, const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);
    const char* line;
    int len = 0;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        len += 1;
    }

    point_t* ps = kt_linear_arena_array(arena, point_t, len);
    len = 0;
    kt_scanner_reset(scanner);
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        point_from(line, ps + len);
        len += 1;
    }
    kt_scanner_deinit(scanner);

    context_t ctx;
    ctx.ps = ps;
    ctx.len = len;
    return ctx;
}

const char* guess_message(const char* input_file)
{
    void* arena = kt_linear_arena_init(1 * 1024 * 1024);
    context_t ctx = context_init(arena, input_file);

    const char* result = guess_message_impl(arena, ctx.ps, ctx.len);

    kt_linear_arena_deinit(arena);

    return result;
}

int wait_seconds(const char* input_file)
{
    void* arena = kt_linear_arena_init(1 * 1024 * 1024);
    context_t ctx = context_init(arena, input_file);

    int result = wait_seconds_impl(arena, ctx.ps, ctx.len) + 1;

    kt_linear_arena_deinit(arena);

    return result;
}

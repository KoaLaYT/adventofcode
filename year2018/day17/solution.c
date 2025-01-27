#include "../lib/kt.h"
#include "../lib/re.h"

#define CHAR_SAND '.'
#define CHAR_CLAY '#'
#define CHAR_SPRING '+'
#define CHAR_WATER '~'
#define CHAR_FLOW '|'

#define MIN(a, b) (a) < (b) ? (a) : (b)
#define MAX(a, b) (a) > (b) ? (a) : (b)

typedef struct {
    i32 width, height;
    char* square;
    i32 spring_x;  // spring_y = 0;
    i32 min_y;
} ground_t;

typedef enum {
    clay_dir_vertical,
    clay_dir_horizontal,
} clay_dir_t;

typedef struct {
    clay_dir_t dir;
    i32 v[3];
} clay_t;

static b8 ground_flow_horizontal(ground_t* g, i32 x, i32 y, i32 dx);
static void ground_flow_down(ground_t* g, i32 x, i32 y);

#define NDEBUG
#ifndef NDEBUG
#define DEBUG_GROUND(g)                         \
    {                                           \
        for (i32 y = 0; y < g.height; y++) {    \
            for (i32 x = 0; x < g.width; x++) { \
                i32 idx = y * g.width + x;      \
                printf("%c", g.square[idx]);    \
            }                                   \
            printf("\n");                       \
        }                                       \
    }
#else
#define DEBUG_GROUND(g)
#endif

static clay_t clay_from(const char* s)
{
    clay_t c;

    c.dir = *s == 'x' ? clay_dir_vertical : clay_dir_horizontal;

    re_t pattern = re_compile("\\d+");
    i32 len;
    for (i32 i = 0; i < 3; i++) {
        s += re_matchp(pattern, s, &len);
        c.v[i] = kt_atoi_s(s, len);
        s += len;
    }

    return c;
}

static ground_t ground_init(void* arena, const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);
    const char* line;

    i32 min_x = 2147483647, min_y = 2147483647;
    i32 max_x = 0, max_y = 0;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        clay_t c = clay_from(line);
        if (c.dir == clay_dir_vertical) {
            i32 x = c.v[0];
            i32 y1 = c.v[1];
            i32 y2 = c.v[2];
            min_x = MIN(min_x, x);
            max_x = MAX(max_x, x);
            max_y = MAX(max_y, y2);
            min_y = MIN(min_y, y1);
        } else if (c.dir == clay_dir_horizontal) {
            i32 x1 = c.v[1];
            i32 x2 = c.v[2];
            i32 y = c.v[0];
            min_x = MIN(min_x, x1);
            max_x = MAX(max_x, x2);
            max_y = MAX(max_y, y);
            min_y = MIN(min_y, y);
        }
    }
    kt_scanner_reset(scanner);

    min_x = MAX(0, min_x - 1);
    max_x = max_x + 1;
    i32 width = max_x - min_x + 1;
    i32 height = max_y + 1;
    i32 spring_x = 500 - min_x;
    char* square = kt_linear_arena_array_zero(arena, char, width* height);

    for (i32 y = 0; y < height; y++) {
        for (i32 x = 0; x < width; x++) {
            square[y * width + x] = CHAR_SAND;
        }
    }
    square[spring_x] = CHAR_SPRING;

    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        clay_t c = clay_from(line);
        if (c.dir == clay_dir_vertical) {
            i32 x = c.v[0] - min_x;
            for (i32 y = c.v[1]; y <= c.v[2]; y++) {
                i32 idx = y * width + x;
                square[idx] = CHAR_CLAY;
            }
        } else if (c.dir == clay_dir_horizontal) {
            i32 y = c.v[0];
            for (i32 x = c.v[1] - min_x; x <= c.v[2] - min_x; x++) {
                i32 idx = y * width + x;
                square[idx] = CHAR_CLAY;
            }
        }
    }
    kt_scanner_deinit(scanner);

    ground_t g;
    g.width = width;
    g.height = height;
    g.square = square;
    g.spring_x = spring_x;
    g.min_y = min_y;
    return g;
}

static char* ground_square_at(ground_t* g, i32 x, i32 y)
{
    if (x < 0 || x >= g->width || y >= g->height) return 0;
    i32 idx = y * g->width + x;
    return &(g->square[idx]);
}

static b8 ground_flow_horizontal(ground_t* g, i32 x, i32 y, i32 dx)
{
    for (;;) {
        char* c0 = ground_square_at(g, x, y);
        char* c1 = ground_square_at(g, x, y + 1);
        ASSERT_MSG(c0 != 0 && c1 != 0,  //
                   "flow out of boundary (%d,%d)", x, y);

        if (*c1 == CHAR_SAND) {
            *c0 = CHAR_FLOW;
            ground_flow_down(g, x, y);
        } else if (*c1 == CHAR_FLOW) {
            return FALSE;
        } else if (*c0 == CHAR_CLAY || *c0 == CHAR_WATER) {
            return TRUE;
        } else {
            *c0 = CHAR_FLOW;
            x += dx;
        }
    }
}

static void ground_rest(ground_t* g, i32 x, i32 y)
{
    char* c = ground_square_at(g, x, y);
    ASSERT_MSG(c != 0, "rest out of boundary (%d, %d)", x, y);
    *c = CHAR_WATER;

    for (i32 i = x - 1;; i--) {
        char* c = ground_square_at(g, i, y);
        ASSERT_MSG(c != 0, "rest out of boundary (%d, %d)", x, y);
        if (*c == CHAR_FLOW) {
            *c = CHAR_WATER;
        } else {
            break;
        }
    }

    for (i32 i = x + 1;; i++) {
        char* c = ground_square_at(g, i, y);
        ASSERT_MSG(c != 0, "rest out of boundary (%d, %d)", x, y);
        if (*c == CHAR_FLOW) {
            *c = CHAR_WATER;
        } else {
            break;
        }
    }
}

static void ground_flow_down(ground_t* g, i32 x, i32 y)
{
    for (;;) {
        char* c = ground_square_at(g, x, y + 1);
        if (!c) return;

        if (*c == CHAR_SAND || *c == CHAR_FLOW) {
            *c = CHAR_FLOW;
        } else {
            break;
        }
        y += 1;
    }

    for (; y >= 0; y -= 1) {
        b8 rest_left = ground_flow_horizontal(g, x - 1, y, -1);
        b8 rest_right = ground_flow_horizontal(g, x + 1, y, 1);
        if (!rest_left || !rest_right) return;

        ground_rest(g, x, y);
    }
}

static i32 ground_reached(const ground_t* g)
{
    i32 count = 0;
    for (i32 y = g->min_y; y < g->height; y++) {
        for (i32 x = 0; x < g->width; x++) {
            i32 idx = y * g->width + x;
            char c = g->square[idx];
            if (c == CHAR_FLOW || c == CHAR_WATER) {
                count += 1;
            }
        }
    }
    return count;
}

static i32 ground_retained(const ground_t* g)
{
    i32 count = 0;
    for (i32 y = g->min_y; y < g->height; y++) {
        for (i32 x = 0; x < g->width; x++) {
            i32 idx = y * g->width + x;
            char c = g->square[idx];
            if (c == CHAR_WATER) {
                count += 1;
            }
        }
    }
    return count;
}

i32 reached_tiles(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    ground_t g = ground_init(arena, input_file);
    ground_flow_down(&g, g.spring_x, 0);
    i32 result = ground_reached(&g);
    kt_linear_arena_deinit(arena);
    return result;
}

i32 retained_water(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    ground_t g = ground_init(arena, input_file);
    ground_flow_down(&g, g.spring_x, 0);
    i32 result = ground_retained(&g);
    kt_linear_arena_deinit(arena);
    return result;
}

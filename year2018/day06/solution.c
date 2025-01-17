#include <stdio.h>

#include "../lib/kt.h"
#define ABS(x) ((x) < 0 ? -(x) : (x))
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) < (b) ? (b) : (a))

typedef struct {
    int x;
    int y;
} coord_t;

typedef struct {
    coord_t* coords;
    int len;
    int min_x;
    int min_y;
    int max_x;
    int max_y;
} context_t;

static void coord_from(const char* s, coord_t* coord)
{
    int i = 0;
    while (s[i] != ',') i += 1;
    coord->x = kt_atoi_s(s, i);
    coord->y = kt_atoi(s + i + 2);
}

static int manhattan_distance(const coord_t* coord, int x, int y)
{
    return ABS(coord->x - x) + ABS(coord->y - y);
}

static int find_closest(const coord_t* coords, int len, int x, int y)
{
    int min_length = 2147483647;
    int same = 0;
    int idx = 0;
    for (int i = 0; i < len; i++) {
        int d = manhattan_distance(coords + i, x, y);
        if (d < min_length) {
            min_length = d;
            same = 1;
            idx = i;
        } else if (d == min_length) {
            same += 1;
        }
    }
    return same == 1 ? idx : -1;
}

static int* mark_infinite_coord_ids(void* arena,                       //
                                    int len,                           //
                                    int* grid, int width, int height)  //
{
    int* infinite_coord_ids = kt_linear_arena_array_zero(arena, int, len);

    // first row
    for (int i = 0; i < width; i++) {
        int coord_id = grid[i];
        if (coord_id >= 0) {
            infinite_coord_ids[coord_id] += 1;
        }
    }

    // last row
    for (int i = 0; i < width; i++) {
        int coord_id = grid[width * (height - 1) + i];
        if (coord_id >= 0) {
            infinite_coord_ids[coord_id] += 1;
        }
    }

    // first col
    for (int i = 0; i < height; i++) {
        int coord_id = grid[i * width];
        if (coord_id >= 0) {
            infinite_coord_ids[coord_id] += 1;
        }
    }

    // last col
    for (int i = 0; i < height; i++) {
        int coord_id = grid[i * width + width - 1];
        if (coord_id >= 0) {
            infinite_coord_ids[coord_id] += 1;
        }
    }

    return infinite_coord_ids;
}

static int array_max(int* arr, int len)
{
    int max = 0;
    for (int i = 0; i < len; i++) {
        int v = arr[i];
        if (v > max) {
            max = v;
        }
    }
    return max;
}

static int largest_area_impl(void* arena, context_t ctx)
{
    int width = ctx.max_x - ctx.min_x + 1;
    int height = ctx.max_y - ctx.min_y + 1;
    int* grid = kt_linear_arena_array(arena, int, width* height);

    for (int i = 0; i < ctx.len; i++) {
        ctx.coords[i].x -= ctx.min_x;
        ctx.coords[i].y -= ctx.min_y;
    }

    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            grid[x + y * width] = find_closest(ctx.coords, ctx.len, x, y);
        }
    }

    int* infinite_coord_ids =
        mark_infinite_coord_ids(arena, ctx.len, grid, width, height);

    int* coord_areas = kt_linear_arena_array_zero(arena, int, ctx.len);

    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int id = grid[x + y * width];
            if (id < 0 || infinite_coord_ids[id] > 0) continue;
            coord_areas[id] += 1;
        }
    }

    return array_max(coord_areas, ctx.len);
}

static int calculate_sum(coord_t* coords, int len, int x, int y)
{
    int sum = 0;
    for (int i = 0; i < len; i++) {
        sum += manhattan_distance(coords + i, x, y);
    }
    return sum;
}

static int safe_region_impl(context_t ctx, int safe_size)
{
    int width = ctx.max_x - ctx.min_x + 1;
    int height = ctx.max_y - ctx.min_y + 1;

    for (int i = 0; i < ctx.len; i++) {
        ctx.coords[i].x -= ctx.min_x;
        ctx.coords[i].y -= ctx.min_y;
    }

    int expand_tl = safe_size;
    for (; expand_tl >= 0; expand_tl--) {
        int sum = calculate_sum(ctx.coords, ctx.len, expand_tl, expand_tl);
        if (sum < safe_size) {
            break;
        }
    }
    expand_tl += 1;

    int expand_br = safe_size;
    for (; expand_br >= 0; expand_br--) {
        int sum = calculate_sum(ctx.coords, ctx.len,  //
                                expand_br + width, expand_br + height);
        if (sum < safe_size) {
            break;
        }
    }
    expand_br += 1;

    int count = 0;
    for (int y = -expand_tl; y < height + expand_br; y++) {
        for (int x = -expand_tl; x < width + expand_br; x++) {
            int sum = calculate_sum(ctx.coords, ctx.len, x, y);
            if (sum < safe_size) {
                count += 1;
            }
        }
    }
    return count;
}

static context_t context_init(void* arena, const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);
    const char* line;
    int len = 0;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        len += 1;
    }

    kt_scanner_reset(scanner);
    coord_t* coords = kt_linear_arena_array(arena, coord_t, len);
    len = 0;

    int min_x = 2147483647, min_y = 2147483647;
    int max_x = 0, max_y = 0;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        coord_from(line, coords + len);
        min_x = MIN(min_x, coords[len].x);
        min_y = MIN(min_y, coords[len].y);
        max_x = MAX(max_x, coords[len].x);
        max_y = MAX(max_y, coords[len].y);
        len += 1;
    }
    kt_scanner_deinit(scanner);

    context_t ctx;
    ctx.coords = coords;
    ctx.len = len;
    ctx.min_x = min_x;
    ctx.min_y = min_y;
    ctx.max_x = max_x;
    ctx.max_y = max_y;
    return ctx;
}

int largest_area(const char* input_file)
{
    void* arena = kt_linear_arena_init(1 * 1024 * 1024);
    context_t ctx = context_init(arena, input_file);

    int result = largest_area_impl(arena, ctx);

    kt_linear_arena_deinit(arena);

    return result;
}

int safe_region(const char* input_file)
{
    void* arena = kt_linear_arena_init(1 * 1024 * 1024);
    context_t ctx = context_init(arena, input_file);

    int result = safe_region_impl(ctx, 10000);

    kt_linear_arena_deinit(arena);

    return result;
}

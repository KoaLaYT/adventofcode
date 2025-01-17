#include "solution.c"

#include "../lib/test.h"

static context_t test_context_init(void* arena)
{
    coord_t* coords = kt_linear_arena_array(arena, coord_t, 6);
    coord_from("1, 1", coords + 0);
    coord_from("1, 6", coords + 1);
    coord_from("8, 3", coords + 2);
    coord_from("3, 4", coords + 3);
    coord_from("5, 5", coords + 4);
    coord_from("8, 9", coords + 5);

    context_t ctx;
    ctx.coords = coords;
    ctx.len = 6;
    ctx.min_x = 1;
    ctx.min_y = 1;
    ctx.max_x = 8;
    ctx.max_y = 9;
    return ctx;
}

TEST(test_coord_from)
{
    {
        coord_t c;
        coord_from("1, 1", &c);
        EXPECT(c.x == 1, "expect 1, got %d", c.x);
        EXPECT(c.y == 1, "expect 1, got %d", c.y);
    }
    {
        coord_t c;
        coord_from("123, 456", &c);
        EXPECT(c.x == 123, "expect 123, got %d", c.x);
        EXPECT(c.y == 456, "expect 456, got %d", c.y);
    }
}

TEST(test_find_closest)
{
    typedef struct {
        int x, y;
        int expect;
    } test_case;

    const test_case test_cases[] = {
        {0, 0, 0},
        {3, 2, 3},
        {5, 1, -1},
    };

    void* arena = kt_linear_arena_init(10 * 1024 * 1024);
    context_t ctx = test_context_init(arena);

    for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_case); i++) {
        test_case tt = test_cases[i];
        int got = find_closest(ctx.coords, ctx.len, tt.x, tt.y);
        EXPECT(got == tt.expect, "expect %d, got %d", tt.expect, got);
    }

    kt_linear_arena_deinit(arena);
}

TEST(test_largest_area_impl)
{
    void* arena = kt_linear_arena_init(10 * 1024 * 1024);
    context_t ctx = test_context_init(arena);

    int got = largest_area_impl(arena, ctx);
    EXPECT(got == 17, "expect 17, got %d", got);

    kt_linear_arena_deinit(arena);
}

TEST(test_safe_region_impl)
{
    void* arena = kt_linear_arena_init(10 * 1024 * 1024);
    context_t ctx = test_context_init(arena);

    int got = safe_region_impl(ctx, 32);
    EXPECT(got == 16, "expect 16, got %d", got);

    kt_linear_arena_deinit(arena);
}

TEST_MAIN(test_coord_from, test_find_closest, test_largest_area_impl,
          test_safe_region_impl)

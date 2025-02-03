#include "solution.c"

#include "../lib/test.h"

TEST(test_nanobot_from)
{
    nanobot_t got =
        nanobot_from("pos=<52367881,37530755,-14003664>, r=79178999");

    i32 expects[] = {52367881, 37530755, -14003664, 79178999};
    EXPECT(got.x == expects[0], "expect %d, got %d", expects[0], got.x);
    EXPECT(got.y == expects[1], "expect %d, got %d", expects[1], got.y);
    EXPECT(got.z == expects[2], "expect %d, got %d", expects[2], got.z);
    EXPECT(got.r == expects[3], "expect %d, got %d", expects[3], got.r);
}

TEST(test_context_init)
{
    void* arena = kt_linear_arena_init(1024);
    context_t got = context_init(arena, "./day23/example.txt");
    EXPECT(got.len == 9, "expect 9, got %d", got.len);
    kt_linear_arena_deinit(arena);
}

TEST(test_in_range_impl)
{
    void* arena = kt_linear_arena_init(1024);
    context_t ctx = context_init(arena, "./day23/example.txt");
    i32 got = in_range_impl(ctx);
    EXPECT(got == 7, "expect 7, got %d", got);
    kt_linear_arena_deinit(arena);
}

TEST(test_largest_in_range_impl)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    context_t ctx = context_init(arena, "./day23/example1.txt");
    i32 got = largest_in_range_impl(ctx);
    EXPECT(got == 36, "expect 36, got %d", got);
    kt_linear_arena_deinit(arena);
}

TEST_MAIN(test_nanobot_from, test_context_init,  //
          test_in_range_impl, test_largest_in_range_impl)

#include "solution.c"

#include "../lib/test.h"

TEST(test_risk_level_impl)
{
    void* arena = kt_linear_arena_init(64 * 1024 * 1024);
    i32 got = risk_level_impl(arena, 10, 10, 510);
    EXPECT(got == 114, "expect 114, got %d", got);
    kt_linear_arena_deinit(arena);
}

TEST(test_reach_target_impl)
{
    void* arena = kt_linear_arena_init(64 * 1024 * 1024);
    i32 got = reach_target_impl(arena, 10, 10, 510);
    EXPECT(got == 45, "expect 45, got %d", got);
    kt_linear_arena_deinit(arena);
}

TEST_MAIN(test_risk_level_impl, test_reach_target_impl)

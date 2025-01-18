#include "solution.c"

#include "../lib/test.h"

TEST(test_metadata_sum_impl)
{
    int arr[] = {2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2};
    int got = metadata_sum_impl(arr, sizeof(arr) / sizeof(int));
    EXPECT(got == 138, "expect 138, got %d", got);
}

TEST(test_node_value_impl)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    int arr[] = {2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2};
    int got = node_value_impl(arena, arr, sizeof(arr) / sizeof(int));
    EXPECT(got == 66, "expect 66, got %d", got);
    kt_linear_arena_deinit(arena);
}

TEST_MAIN(test_metadata_sum_impl, test_node_value_impl)

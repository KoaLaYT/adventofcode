#include "solution.c"

#include "../lib/test.h"

TEST(test_highest_score_impl)
{
    typedef struct {
        int player_len;
        int last;
        int expect;
    } test_case;

    const test_case test_cases[] = {
        {9, 25, 32},      {10, 1618, 8317},  {13, 7999, 146373},
        {17, 1104, 2764}, {21, 6111, 54718}, {30, 5807, 37305},
    };

    for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_case); i++) {
        test_case tt = test_cases[i];
        void* arena = kt_linear_arena_init(1024 * 1024);
        int got = highest_score_impl(arena, tt.player_len, tt.last);
        EXPECT(got == tt.expect, "expect %d, got %d", tt.expect, got);
        kt_linear_arena_deinit(arena);
    }
}

TEST_MAIN(test_highest_score_impl)

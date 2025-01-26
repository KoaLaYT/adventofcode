#include "solution.c"

#include "../lib/test.h"

TEST(test_ten_recipes_impl)
{
    typedef struct {
        int recipes;
        const char* expect;
    } test_case;

    const test_case test_cases[] = {
        {9, "5158916779"},
        {5, "0124515891"},
        {18, "9251071085"},
        {2018, "5941429882"},
    };

    for (int i = 0; i < sizeof(test_cases) / sizeof(test_case); i++) {
        void* arena = kt_linear_arena_init(1024 * 1024);
        test_case tt = test_cases[i];
        const char* got = ten_recipes_impl(arena, tt.recipes);
        EXPECT(strcmp(got, tt.expect) == 0, "expect %s, got %s",  //
               tt.expect, got);
        free((void*)got);
        kt_linear_arena_deinit(arena);
    }
}

TEST(test_recipes_util_impl)
{
    typedef struct {
        const char* target;
        int expect;
    } test_case;

    const test_case test_cases[] = {
        {"51589", 9},
        {"01245", 5},
        {"92510", 18},
        {"59414", 2018},
    };

    for (int i = 0; i < sizeof(test_cases) / sizeof(test_case); i++) {
        void* arena = kt_linear_arena_init(CAP);
        test_case tt = test_cases[i];
        int got = recipes_until_impl(arena, tt.target);
        EXPECT(got == tt.expect, "expect %d, got %d", tt.expect, got);
        kt_linear_arena_deinit(arena);
    }
}

TEST_MAIN(test_ten_recipes_impl, test_recipes_util_impl)

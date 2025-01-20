#include "solution.c"

#include "../lib/test.h"

TEST(test_power_level)
{
    typedef struct {
        int x, y, serial_num;
        int expect;
    } test_case;

    const test_case test_cases[] = {
        {3, 5, 8, 4},      {122, 79, 57, -5}, {217, 196, 39, 0},
        {101, 153, 71, 4}, {33, 45, 18, 4},   {34, 45, 18, 4},
        {35, 45, 18, 4},   {33, 46, 18, 3},   {32, 44, 18, -2},
    };

    for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_cases[0]); i++) {
        test_case tt = test_cases[i];
        int got = power_level(tt.x, tt.y, tt.serial_num);
        EXPECT(got == tt.expect, "expect %d, got %d", tt.expect, got);
    }
}

TEST(test_largest_33_impl)
{
    typedef struct {
        int serial_num;
        const char* expect;
    } test_case;

    const test_case test_cases[] = {
        {18, "33,45"},
        {42, "21,61"},
    };

    for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_cases[0]); i++) {
        test_case tt = test_cases[i];
        const char* got = largest_33_impl(tt.serial_num);
        EXPECT(strcmp(got, tt.expect) == 0,  //
               "expect %s, got %s", tt.expect, got);
        free((void*)got);
    }
}

TEST(test_largest_impl)
{
    typedef struct {
        int serial_num;
        const char* expect;
    } test_case;

    const test_case test_cases[] = {
        {18, "90,269,16"},
        {42, "232,251,12"},
    };

    for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_cases[0]); i++) {
        test_case tt = test_cases[i];
        const char* got = largest_impl(tt.serial_num);
        EXPECT(strcmp(got, tt.expect) == 0,  //
               "expect %s, got %s", tt.expect, got);
        free((void*)got);
    }
}

TEST_MAIN(test_power_level, test_largest_33_impl, test_largest_impl)

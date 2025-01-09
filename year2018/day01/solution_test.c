#include "solution.c"

#include "../lib/test.h"

TEST(test_parse_row)
{
    typedef struct {
        const char* input;
        int expect;
    } test_case;

    const test_case test_cases[] = {
        {"-1", -1}, {"1", 1}, {"+1", 1}, {"+123", 123}, {"-123", -123},
    };

    for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_cases[0]); i++) {
        test_case tt = test_cases[i];
        int got = parse_row(tt.input);
        EXPECT(got == tt.expect, "expect %d, got %d", tt.expect, got);
    }
}

TEST(test_find_twice_frequency)
{
    {
        int arr[] = {1, -1};
        int expect = 0;
        int got = find_twice_frequency(arr, sizeof(arr) / sizeof(arr[0]));
        EXPECT(got == expect, "expect %d, got %d", expect, got);
    }
    {
        int arr[] = {3, 3, 4, -2, -4};
        int expect = 10;
        int got = find_twice_frequency(arr, sizeof(arr) / sizeof(arr[0]));
        EXPECT(got == expect, "expect %d, got %d", expect, got);
    }
    {
        int arr[] = {-6, 3, 8, 5, -6};
        int expect = 5;
        int got = find_twice_frequency(arr, sizeof(arr) / sizeof(arr[0]));
        EXPECT(got == expect, "expect %d, got %d", expect, got);
    }
    {
        int arr[] = {7, 7, -2, -7, -4};
        int expect = 14;
        int got = find_twice_frequency(arr, sizeof(arr) / sizeof(arr[0]));
        EXPECT(got == expect, "expect %d, got %d", expect, got);
    }
}

TEST_MAIN(test_parse_row, test_find_twice_frequency)

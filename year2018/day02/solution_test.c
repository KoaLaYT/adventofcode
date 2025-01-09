#include "solution.c"

#include "../lib/test.h"

TEST(test_count_letters)
{
    typedef struct {
        const char* input;
        int num;
        int expect;
    } test_case;

    const test_case test_cases[] = {
        {"abcdef", 2, 0},
        {"bababc", 2, 1},
        {"bababc", 3, 1},
    };

    for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_cases[0]); i++) {
        test_case tt = test_cases[i];
        int got = count_letters(tt.input, tt.num);
        EXPECT(got == tt.expect, "expect %d, got %d", tt.expect, got);
    }
}

TEST(test_diff)
{
    typedef struct {
        const char* s1;
        const char* s2;
        int expect;
    } test_case;

    const test_case test_cases[] = {
        {"abcde", "axcye", 2},
    };

    for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_cases[0]); i++) {
        test_case tt = test_cases[i];
        int got = diff(tt.s1, tt.s2);
        EXPECT(got == tt.expect, "expect %d, got %d", tt.expect, got);
    }
}

TEST_MAIN(test_count_letters, test_diff)

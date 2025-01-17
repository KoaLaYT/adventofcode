#include "solution.c"

#include <stdlib.h>

#include "../lib/test.h"

TEST(test_remain_after_reaction)
{
    typedef struct {
        const char* input;
        int expect;
    } test_case;

    const test_case test_cases[] = {
        {"aA", 0},
        {"abBA", 0},
        {"aabAAB", 6},
        {"dabAcCaCBAcCcaDA", 10},
    };

    for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_cases[0]); i++) {
        test_case tt = test_cases[i];
        int len = strlen(tt.input);
        char* buf = malloc(len + 1);
        strcpy(buf, tt.input);
        int got = remain_after_reaction(buf, len);
        EXPECT(got == tt.expect, "expect %d, got %d", tt.expect, got);
        free(buf);
    }
}

TEST(test_find_shortest)
{
    typedef struct {
        const char* input;
        int expect;
    } test_case;

    const test_case test_cases[] = {
        {"dabAcCaCBAcCcaDA", 4},
    };

    for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_cases[0]); i++) {
        test_case tt = test_cases[i];
        int len = strlen(tt.input);
        char* buf = malloc(len + 1);
        strcpy(buf, tt.input);
        int got = find_shortest(buf);
        EXPECT(got == tt.expect, "expect %d, got %d", tt.expect, got);
        free(buf);
    }
}

TEST_MAIN(test_remain_after_reaction, test_find_shortest)

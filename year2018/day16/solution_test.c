#include "solution.c"

#include "../lib/test.h"

#define EXPECT_ARR_EQUAL(expect, got)                                   \
    {                                                                   \
        for (int i = 0; i < SIZE; i++) {                                \
            EXPECT(expect[i] == got[i], "idx %d: expect %d, got %d", i, \
                   expect[i], got[i]);                                  \
        }                                                               \
    }

TEST(test_count_behaves_impl)
{
    const int regs_before[] = {3, 2, 1, 1};
    const int codes[] = {9, 2, 1, 2};
    const int regs_after[] = {3, 2, 2, 1};
    int counts[OP_TOTAL] = {0};

    count_behaves_impl(regs_before, regs_after, codes, counts);
    int got = 0;
    for (int i = 0; i < OP_TOTAL; i++) {
        if (counts[i] > 0) {
            got += 1;
        }
    }
    EXPECT(got == 3, "expect 3, got %d", got);
}

TEST(test_parse_sample)
{
    const char* before = "Before: [13, 2, 1, 1]";
    const char* opcodes = "9 2 1 12";
    const char* after = "After:  [3, 2, 2, 1]";

    int regs_before[SIZE];
    int codes[SIZE];
    int regs_after[SIZE];
    parse_sample(before, opcodes, after, regs_before, codes, regs_after);

    int regs_before_expect[] = {13, 2, 1, 1};
    int codes_expect[] = {9, 2, 1, 12};
    int regs_after_expect[] = {3, 2, 2, 1};

    EXPECT_ARR_EQUAL(regs_before_expect, regs_before);
    EXPECT_ARR_EQUAL(codes_expect, codes);
    EXPECT_ARR_EQUAL(regs_after_expect, regs_after);
}

TEST_MAIN(test_count_behaves_impl, test_parse_sample);

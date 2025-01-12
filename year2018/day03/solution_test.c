#include "solution.c"

#include "../lib/test.h"

TEST(test_count_overlaps)
{
    claim_t claims[] = {
        {1, 3, 4, 4},
        {3, 1, 4, 4},
        {5, 5, 2, 2},
    };
    int got = count_overlaps(7, 7, claims, 3);
    EXPECT(got == 4, "expect 2, got %d", got);
}

TEST(test_parse_claim)
{
    claim_t claim;
    parse_claim("#123 @ 123,456: 22x33", &claim);

    EXPECT(claim.left == 123, "expect 123, got %d", claim.left);
    EXPECT(claim.top == 456, "expect 456, got %d", claim.top);
    EXPECT(claim.width == 22, "expect 22, got %d", claim.width);
    EXPECT(claim.height == 33, "expect 33, got %d", claim.height);
}

TEST(test_find_none_overlap)
{
    claim_t claims[] = {
        {1, 3, 4, 4},
        {3, 1, 4, 4},
        {5, 5, 2, 2},
    };
    int got = find_none_overlap(7, 7, claims, 3);
    EXPECT(got == 3, "expect 3, got %d", got);
}

TEST_MAIN(test_count_overlaps, test_parse_claim, test_find_none_overlap)

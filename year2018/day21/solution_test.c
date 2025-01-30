#include "../lib/test.h"

TEST(test_empty) { EXPECT(1 == 1, "%s", ""); }

TEST_MAIN(test_empty);

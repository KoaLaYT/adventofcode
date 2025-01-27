#include "solution.c"

#include "../lib/test.h"

TEST(test_lumber_init)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    lumber_t got = lumber_init(arena, "./day18/example.txt");
    EXPECT(got.width == 10, "expect 10, got %d", got.width);
    EXPECT(got.height == 10, "expect 10, got %d", got.height);

    {
        const char* expect[] = {
            ".#.#...|#.", ".....#|##|", ".|..|...#.", "..|#.....#",
            "#.#|||#|#|", "...#.||...", ".|....|...", "||...#|.#|",
            "|.||||..|.", "...#.|..|.",
        };
        for (i32 y = 0; y < 10; y++) {
            for (i32 x = 0; x < 10; x++) {
                i32 idx = y * 10 + x;
                EXPECT(got.acres[idx] == expect[y][x],  //
                       "expect %c, got %c", expect[y][x], got.acres[idx]);
            }
        }
    }

    kt_linear_arena_deinit(arena);
}

TEST(test_lumber_change)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    lumber_t l = lumber_init(arena, "./day18/example.txt");

    for (i32 round = 0; round < 10; round++) {
        lumber_change(&l);
        DEBUG_LUMBER(l);
    }
    i32 trees = lumber_count(&l, CHAR_TREE);
    i32 yards = lumber_count(&l, CHAR_YARD);
    EXPECT(trees == 37, "expect 37, got %d", trees);
    EXPECT(yards == 31, "expect 31, got %d", yards);

    kt_linear_arena_deinit(arena);
}

TEST_MAIN(test_lumber_init, test_lumber_change)

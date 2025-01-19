#include "solution.c"

#include "../lib/test.h"

TEST(test_point_from)
{
    point_t p;
    point_from("position=< 3, -2> velocity=<-1,  1>", &p);
    EXPECT(p.x == 3, "expect 3, got %d", p.x);
    EXPECT(p.y == -2, "expect -2, got %d", p.x);
    EXPECT(p.vx == -1, "expect -1, got %d", p.vx);
    EXPECT(p.vy == 1, "expect 1, got %d", p.vy);
}

TEST(test_guess_message_impl)
{
    const char* input[] = {
        "position=< 9,  1> velocity=< 0,  2>",
        "position=< 7,  0> velocity=<-1,  0>",
        "position=< 3, -2> velocity=<-1,  1>",
        "position=< 6, 10> velocity=<-2, -1>",
        "position=< 2, -4> velocity=< 2,  2>",
        "position=<-6, 10> velocity=< 2, -2>",
        "position=< 1,  8> velocity=< 1, -1>",
        "position=< 1,  7> velocity=< 1,  0>",
        "position=<-3, 11> velocity=< 1, -2>",
        "position=< 7,  6> velocity=<-1, -1>",
        "position=<-2,  3> velocity=< 1,  0>",
        "position=<-4,  3> velocity=< 2,  0>",
        "position=<10, -3> velocity=<-1,  1>",
        "position=< 5, 11> velocity=< 1, -2>",
        "position=< 4,  7> velocity=< 0, -1>",
        "position=< 8, -2> velocity=< 0,  1>",
        "position=<15,  0> velocity=<-2,  0>",
        "position=< 1,  6> velocity=< 1,  0>",
        "position=< 8,  9> velocity=< 0, -1>",
        "position=< 3,  3> velocity=<-1,  1>",
        "position=< 0,  5> velocity=< 0, -1>",
        "position=<-2,  2> velocity=< 2,  0>",
        "position=< 5, -2> velocity=< 1,  2>",
        "position=< 1,  4> velocity=< 2,  1>",
        "position=<-2,  7> velocity=< 2, -2>",
        "position=< 3,  6> velocity=<-1, -1>",
        "position=< 5,  0> velocity=< 1,  0>",
        "position=<-6,  0> velocity=< 2,  0>",
        "position=< 5,  9> velocity=< 1, -2>",
        "position=<14,  7> velocity=<-2,  0>",
        "position=<-3,  6> velocity=< 2, -1>",
    };
    int len = sizeof(input) / sizeof(input[0]);
    void* arena = kt_linear_arena_init(10 * 1024 * 1024);
    point_t* ps = kt_linear_arena_array(arena, point_t, len);
    for (int i = 0; i < len; i++) {
        point_from(input[i], ps + i);
    }

    int wait = wait_seconds_impl(arena, ps, len) + 1;
    const char* got = guess_message_impl(arena, ps, len);
    const char* expect =
        "\n"
        "#...#..###\n"
        "#...#...#.\n"
        "#...#...#.\n"
        "#####...#.\n"
        "#...#...#.\n"
        "#...#...#.\n"
        "#...#...#.\n"
        "#...#..###\n";
    EXPECT(strcmp(got, expect) == 0, "expect %s, got %s", expect, got);
    EXPECT(wait == 3, "expect 3, got %d", wait);

    kt_linear_arena_deinit(arena);
}

TEST_MAIN(test_point_from, test_guess_message_impl)

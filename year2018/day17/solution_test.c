#include "solution.c"

#include "../lib/test.h"

TEST(test_clay_from)
{
    typedef struct {
        const char* input;
        clay_t expect;
    } test_case;

    const test_case test_cases[] = {
        {
            "x=495, y=2..7",
            {clay_dir_vertical, {495, 2, 7}},
        },
        {
            "y=7, x=495..501",
            {clay_dir_horizontal, {7, 495, 501}},
        },
    };

    for (u64 i = 0; i < sizeof(test_cases) / sizeof(test_case); i++) {
        test_case tt = test_cases[i];
        clay_t got = clay_from(tt.input);
        EXPECT(got.dir == tt.expect.dir, "expect %d, got %d",  //
               tt.expect.dir, got.dir);
        EXPECT(got.v[0] == tt.expect.v[0], "expect %d, got %d",  //
               tt.expect.v[0], got.v[0]);
        EXPECT(got.v[1] == tt.expect.v[1], "expect %d, got %d",  //
               tt.expect.v[1], got.v[1]);
        EXPECT(got.v[2] == tt.expect.v[2], "expect %d, got %d",  //
               tt.expect.v[2], got.v[2]);
    }
}

TEST(test_ground)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    ground_t g = ground_init(arena, "./day17/example.txt");
    ground_flow_down(&g, g.spring_x, 0);
    DEBUG_GROUND(g);
    {
        i32 got = ground_reached(&g);
        EXPECT(got == 57, "expect 57, got %d", got);
    }
    {
        i32 got = ground_retained(&g);
        EXPECT(got == 29, "expect 29, got %d", got);
    }
    kt_linear_arena_deinit(arena);
}

TEST_MAIN(test_clay_from, test_ground)

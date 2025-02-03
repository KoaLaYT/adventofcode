#include "solution.c"

#include "../lib/test.h"

TEST(test_point_from)
{
    point_t p = point_from("-2,-2,-2,2");
    EXPECT(p.x == -2, "expect -2, got %d", p.x);
    EXPECT(p.y == -2, "expect -2, got %d", p.y);
    EXPECT(p.z == -2, "expect -2, got %d", p.z);
    EXPECT(p.w == 2, "expect 2, got %d", p.w);
}

TEST(test_count_constellations_impl)
{
    typedef struct {
        const char* input_file;
        i32 expect;
    } test_case;

    const test_case test_cases[] = {
        {"./day25/example1.txt", 2},
        {"./day25/example2.txt", 4},
        {"./day25/example3.txt", 3},
        {"./day25/example4.txt", 8},
    };

    for (u64 i = 0; i < sizeof(test_cases) / sizeof(test_case); i++) {
        test_case tt = test_cases[i];
        void* arena = kt_linear_arena_init(1024 * 1024);
        points_t ps = points_from(arena, tt.input_file);
        i32 got = count_constellations_impl(arena, ps);
        EXPECT(got == tt.expect, "expect %d, got %d", tt.expect, got);
        kt_linear_arena_deinit(arena);
    }
}

TEST_MAIN(test_point_from, test_count_constellations_impl)

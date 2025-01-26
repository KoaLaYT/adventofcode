#include "solution.c"

#include "../lib/test.h"

TEST(test_game_init)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    game_t got = game_init(arena, "./day15/example1.txt");
    EXPECT(got.width == 7, "expect 7, got %d", got.width);
    EXPECT(got.height == 7, "expect 7, got %d", got.height);
    EXPECT(got.golbin_left == 4, "expect 4, got %d", got.golbin_left);
    EXPECT(got.elf_left == 2, "expect 4, got %d", got.elf_left);

    typedef struct {
        int x, y;
    } unit_test_case;
    {
        const unit_test_case test_cases[] = {
            {2, 1},
            {5, 2},
            {5, 3},
            {3, 4},
        };
        for (int i = 0; i < got.golbin_left; i++) {
            unit_test_case tt = test_cases[i];
            EXPECT(got.golbins[i].x == tt.x, "expect %d, got %d",  //
                   tt.x, got.golbins[i].x);
            EXPECT(got.golbins[i].y == tt.y, "expect %d, got %d",  //
                   tt.y, got.golbins[i].y);
        }
    }
    {
        const unit_test_case test_cases[] = {
            {4, 2},
            {5, 4},
        };
        for (int i = 0; i < got.elf_left; i++) {
            unit_test_case tt = test_cases[i];
            EXPECT(got.elfs[i].x == tt.x, "expect %d, got %d",  //
                   tt.x, got.elfs[i].x);
            EXPECT(got.elfs[i].y == tt.y, "expect %d, got %d",  //
                   tt.y, got.elfs[i].y);
        }
    }
    {
        const char* expect[] = {
            "#######", "#.G...#", "#...EG#", "#.#.#G#",
            "#..G#E#", "#.....#", "#######",
        };
        for (int y = 0; y < got.height; y++) {
            for (int x = 0; x < got.width; x++) {
                char ec = expect[y][x];
                char gc = got.map[y * got.width + x];
                EXPECT(gc == ec, "expect %c, got %c", ec, gc);
            }
        }
    }

    kt_linear_arena_deinit(arena);
}

TEST(test_game_start)
{
    typedef struct {
        const char* input_file;
        int expect;
    } test_case;

    const test_case test_cases[] = {
        {"./day15/example1.txt", 27730}, {"./day15/example2.txt", 36334},
        {"./day15/example3.txt", 39514}, {"./day15/example4.txt", 27755},
        {"./day15/example5.txt", 28944}, {"./day15/example6.txt", 18740},
    };

    for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_case); i++) {
        test_case tt = test_cases[i];
        void* arena = kt_linear_arena_init(1024 * 1024);

        game_t game = game_init(arena, tt.input_file);
        int got = game_start(&game, 0);
        EXPECT(got == tt.expect, "expect %d, got %d", tt.expect, got);

        kt_linear_arena_deinit(arena);
    }
}

TEST(test_game_start2)
{
    typedef struct {
        const char* input_file;
        int expect;
    } test_case;

    const test_case test_cases[] = {
        {"./day15/example1.txt", 4988}, {"./day15/example3.txt", 31284},
        {"./day15/example4.txt", 3478}, {"./day15/example5.txt", 6474},
        {"./day15/example6.txt", 1140},
    };

    for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_case); i++) {
        test_case tt = test_cases[i];
        void* arena = kt_linear_arena_init(1024 * 1024);

        game_t game = game_init(arena, tt.input_file);
        int got = game_start2(arena, &game);
        EXPECT(got == tt.expect, "expect %d, got %d", tt.expect, got);

        kt_linear_arena_deinit(arena);
    }
}

TEST_MAIN(test_game_init, test_game_start, test_game_start2)

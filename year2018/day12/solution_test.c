#include "solution.c"

#include "../lib/test.h"

static void notes_init(char* notes)
{
    const char* input[] = {
        "...## => #", "..#.. => #", ".#... => #", ".#.#. => #", ".#.## => #",
        ".##.. => #", ".#### => #", "#.#.# => #", "#.### => #", "##.#. => #",
        "##.## => #", "###.. => #", "###.# => #", "####. => #",
    };
    for (int i = 0; i < sizeof(input) / sizeof(input[0]); i++) {
        note_parse(input[i], notes);
    }
}

TEST(test_note_parse)
{
    typedef struct {
        const char* input;
        int expect_i;
        char expect_v;
    } test_case;

    const test_case test_cases[] = {
        {"...## => #", 3, 1},
        {"..#.. => #", 4, 1},
        {"####. => #", 30, 1},
    };

    for (int i = 0; i < sizeof(test_cases) / sizeof(test_cases[0]); i++) {
        test_case tt = test_cases[i];
        char notes[32] = {0};
        memset(notes, 0, 32);
        note_parse(tt.input, notes);
        EXPECT(notes[tt.expect_i] == tt.expect_v,  //
               "expect %d, got %d", tt.expect_v, notes[tt.expect_i]);
    }
}

TEST(test_plant_from)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    plant_t p = plant_from(arena, "#..#.#..##......###...###");

    EXPECT(p.head == 500, "expect 500, got %ld", p.head);
    EXPECT(p.tail == 524, "expect 524, got %ld", p.tail);

    kt_linear_arena_deinit(arena);
}

TEST(test_sum_plants_impl)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    char notes[32] = {0};
    notes_init(notes);

    plant_t p = plant_from(arena, "#..#.#..##......###...###");

    int got = sum_plants_impl(&p, notes, 20);
    EXPECT(got == 325, "expect 325, got %d", got);

    kt_linear_arena_deinit(arena);
}

TEST_MAIN(test_note_parse, test_plant_from, test_sum_plants_impl)

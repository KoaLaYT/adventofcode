#include "solution.c"

#include "../lib/test.h"

static requirement_t* prepare_requirements(void* arena)
{
    requirement_t* rs = kt_linear_arena_array(arena, requirement_t, 7);
    const char* input[7] = {
        "Step C must be finished before step A can begin.",
        "Step C must be finished before step F can begin.",
        "Step A must be finished before step B can begin.",
        "Step A must be finished before step D can begin.",
        "Step B must be finished before step E can begin.",
        "Step D must be finished before step E can begin.",
        "Step F must be finished before step E can begin.",
    };
    for (int i = 0; i < 7; i++) {
        requirement_from(input[i], rs + i);
    }
    return rs;
}

TEST(test_requirement_from)
{
    const char* input = "Step A must be finished before step D can begin.";
    requirement_t r;
    requirement_from(input, &r);
    EXPECT(r.step == 'D', "expect D, got %c", r.step);
    EXPECT(r.deps == 'A', "expect A, got %c", r.deps);
}

TEST(test_steps_order)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    requirement_t* rs = prepare_requirements(arena);
    const char* got = steps_order_impl(arena, rs, 7);
    EXPECT(strcmp(got, "CABDFE") == 0, "expect CABDFE, got %s", got);
    kt_linear_arena_deinit(arena);
}

TEST(test_multiworker_impl)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    requirement_t* rs = prepare_requirements(arena);
    int got = multiworker_impl(arena, rs, 7, 0, 2);
    EXPECT(got == 15, "expect 15, got %d", got);
    kt_linear_arena_deinit(arena);
}

TEST_MAIN(test_requirement_from, test_steps_order, test_multiworker_impl)

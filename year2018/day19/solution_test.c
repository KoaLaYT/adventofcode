#include "solution.c"

#include "../lib/test.h"

TEST(test_instruction_from)
{
    instruction_t got = instruction_from("seti 5 0 1");
    EXPECT(got.type == op_seti, "expect %d, got %d", op_seti, got.type);
    EXPECT(got.a == 5, "expect 5, got %d", got.a);
    EXPECT(got.b == 0, "expect 0, got %d", got.b);
    EXPECT(got.c == 1, "expect 1, got %d", got.c);
}

TEST(test_device_init)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    device_t got = device_init(arena, "./day19/example.txt");
    EXPECT(got.len == 7, "expect 7, got %d", got.len);
    EXPECT(got.bound == 0, "expect 0, got %d", got.bound);
    EXPECT(got.pc == 0, "expect 0, got %d", got.pc);

    kt_linear_arena_deinit(arena);
}

TEST(test_device_exec)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    device_t d = device_init(arena, "./day19/example.txt");
    device_exec(&d);

    {
        i32 expect[] = {6, 5, 6, 0, 0, 9};
        for (i32 i = 0; i < REG_SIZE; i++) {
            EXPECT(d.regs[i] == expect[i],  //
                   "expect %d, got %d", expect[i], d.regs[i]);
        }
    }

    kt_linear_arena_deinit(arena);
}

TEST_MAIN(test_instruction_from, test_device_init, test_device_exec)

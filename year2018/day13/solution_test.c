#include "solution.c"

#include "../lib/test.h"

TEST(test_parse_line)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    track_t track = track_init(arena, 13, 6);
    cart_t* carts = kt_linear_arena_array_zero(arena, cart_t, 10);
    int cart_len = 0;

    {
        parse_line("/->-\\", &track, 0, carts, &cart_len);
        const char* expect = "/---\\";
        for (size_t i = 0; i < strlen(expect); i++) {
            EXPECT(track.arr[i] == expect[i],  //
                   "expect %c, got %c", expect[i], track.arr[0]);
        }
        EXPECT(cart_len == 1, "expect 1, got %d", cart_len);
        EXPECT(carts[0].x == 2, "expect 2, got %d", carts[0].x);
        EXPECT(carts[0].y == 0, "expect 0, got %d", carts[0].y);
        EXPECT(carts[0].dir == dir_right,  //
               "expect %d, got %d", dir_right, carts[0].dir);
    }

    {
        parse_line("\\-+-/  \\->--/", &track, 4, carts, &cart_len);
        const char* expect = "\\-+-/  \\----/";
        for (size_t i = 0; i < strlen(expect); i++) {
            EXPECT(track.arr[13 * 4 + i] == expect[i],  //
                   "expect %c, got %c", expect[i], track.arr[0]);
        }
        EXPECT(cart_len == 2, "expect 2, got %d", cart_len);
        EXPECT(carts[1].x == 9, "expect 9, got %d", carts[1].x);
        EXPECT(carts[1].y == 4, "expect 4, got %d", carts[1].y);
        EXPECT(carts[1].dir == dir_right,  //
               "expect %d, got %d", dir_right, carts[1].dir);
    }

    kt_linear_arena_deinit(arena);
}

TEST(test_cart_sort)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    cart_t* carts = kt_linear_arena_array_zero(arena, cart_t, 10);
    carts[0].x = 1, carts[0].y = 2;
    carts[1].x = 1, carts[1].y = 1;
    carts[2].x = 2, carts[2].y = 3;

    cart_sort(carts, 3);
    EXPECT(carts[0].y == 1, "expect 1, got %d", carts[0].y);
    EXPECT(carts[1].y == 2, "expect 2, got %d", carts[1].y);
    EXPECT(carts[2].y == 3, "expect 3, got %d", carts[2].y);

    kt_linear_arena_deinit(arena);
}

TEST(test_first_crash_impl)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    context_t ctx = context_init(arena, "./day13/example1.txt");
    const char* got = first_crash_impl(&ctx.track, ctx.carts, ctx.cart_len);
    EXPECT(strcmp(got, "7,3") == 0, "expect 7,3, got %s", got);

    free((void*)got);
    kt_linear_arena_deinit(arena);
}

TEST(test_last_cart_impl)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    context_t ctx = context_init(arena, "./day13/example2.txt");
    const char* got = last_cart_impl(&ctx.track, ctx.carts, ctx.cart_len);
    EXPECT(strcmp(got, "6,4") == 0, "expect 6,4, got %s", got);

    free((void*)got);
    kt_linear_arena_deinit(arena);
}

TEST_MAIN(test_parse_line, test_cart_sort, test_first_crash_impl,
          test_last_cart_impl)

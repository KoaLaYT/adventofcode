#include "solution.c"

#include "../lib/test.h"

TEST(test_type_pool)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    type_pool_t pool = type_pool_init(arena, 1024);
    {
        i32 id = type_pool_get(&pool, "fire", 4);
        EXPECT(strcmp("fire", pool.vals[id]) == 0,  //
               "expect fire, got %s", pool.vals[id]);
    }
    {
        i32 id = type_pool_get(&pool, "cold", 4);
        EXPECT(strcmp("cold", pool.vals[id]) == 0,  //
               "expect cold, got %s", pool.vals[id]);
    }
    for (i32 i = 0; i < 1000; i++) {
        i32 id = type_pool_get(&pool, "fire", 4);
        EXPECT(strcmp("fire", pool.vals[id]) == 0,  //
               "expect fire, got %s", pool.vals[id]);
    }
    kt_linear_arena_deinit(arena);
}

TEST(test_group_from)
{
    typedef struct {
        char* input;
        group_t expect;
    } test_case;

    void* arena = kt_linear_arena_init(1024 * 1024);
    type_pool_t pool = type_pool_init(arena, 1024);

#define TYPE_ID(s) type_pool_get(&pool, s, strlen(s))
    const test_case test_cases[] = {
        {
            "457 units each with 4941 hit points with an attack that does 98 "
            "slashing damage at initiative 14",
            {0, 457, 4941, 98, TYPE_ID("slashing"), {0, {0}}, {0, {0}}, 14, 0},
        },
        {
            "1646 units each with 15822 hit points (weak to slashing, cold; "
            "immune to fire) with an attack that does 16 fire damage at "
            "initiative 6",
            {0,
             1646,
             15822,
             16,
             TYPE_ID("fire"),
             {2, {TYPE_ID("slashing"), TYPE_ID("cold")}},
             {1, {TYPE_ID("fire")}},
             6,
             0},
        },
        {
            "422 units each with 7279 hit points (immune to radiation, cold) "
            "with an attack that does 170 bludgeoning damage at initiative 16",
            {0,
             422,
             7279,
             170,
             TYPE_ID("bludgeoning"),
             {0, {0}},
             {2, {TYPE_ID("radiation"), TYPE_ID("cold")}},
             16,
             0},
        }};
#undef TYPE_ID

    for (u64 i = 0; i < sizeof(test_cases) / sizeof(test_case); i++) {
        test_case tt = test_cases[i];
        group_t got = group_from(tt.input, &pool, 1);
        EXPECT(got.units == tt.expect.units,  //
               "expect %d, got %d", tt.expect.units, got.units);
        EXPECT(got.hp == tt.expect.hp,  //
               "expect %d, got %d", tt.expect.hp, got.hp);
        EXPECT(got.damage == tt.expect.damage,  //
               "expect %d, got %d", tt.expect.damage, got.damage);
        EXPECT(got.damage_type == tt.expect.damage_type,  //
               "expect %d, got %d", tt.expect.damage_type, got.damage_type);
        EXPECT(got.initiative == tt.expect.initiative,  //
               "expect %d, got %d", tt.expect.initiative, got.initiative);
        // weak
        EXPECT(got.weak_types.len == tt.expect.weak_types.len,  //
               "expect %d, got %d",                             //
               tt.expect.weak_types.len, got.weak_types.len);
        for (i32 j = 0; j < tt.expect.weak_types.len; j++) {
            EXPECT(got.weak_types.arr[j] == tt.expect.weak_types.arr[j],
                   "expect %d, got %d",  //
                   tt.expect.weak_types.arr[j], got.weak_types.arr[j]);
        }
        // immune
        EXPECT(got.immune_types.len == tt.expect.immune_types.len,  //
               "expect %d, got %d",                                 //
               tt.expect.immune_types.len, got.immune_types.len);
        for (i32 j = 0; j < tt.expect.immune_types.len; j++) {
            EXPECT(got.immune_types.arr[j] == tt.expect.immune_types.arr[j],
                   "expect %d, got %d",  //
                   tt.expect.immune_types.arr[j], got.immune_types.arr[j]);
        }
    }
    kt_linear_arena_deinit(arena);
}

TEST(test_fight_start)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    fight_t f = fight_init(arena, "./day24/example.txt");
    EXPECT(f.immunes_len == 2, "expect 2, got %d", f.immunes_len);
    EXPECT(f.infections_len == 2, "expect 2, got %d", f.infections_len);
    fight_start(&f);
    i32 got = fight_remaining_units(&f);
    EXPECT(got == 5216, "expect 5216, got %d", got);
    kt_linear_arena_deinit(arena);
}

TEST(test_fight_boost_to_win)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    i32 got = fight_boost_to_win(arena, "./day24/example.txt");
    EXPECT(got == 51, "expect 51, got %d", got);
    kt_linear_arena_deinit(arena);
}

TEST_MAIN(test_type_pool, test_group_from,  //
          test_fight_start, test_fight_boost_to_win)

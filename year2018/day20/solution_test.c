#include "solution.c"

#include "../lib/test.h"

TEST(test_hm)
{
    hm_t* m = hm_init();
    {
        room_t* r = hm_get(m, 1, 0);
        EXPECT(m->len == 1, "expect 1, got %d", m->len);
        EXPECT(r->x == 1, "expect 1, got %d", r->x);
        EXPECT(r->y == 0, "expect 1, got %d", r->y);
    }
    {
        room_t* r = hm_get(m, 1, 1);
        EXPECT(m->len == 2, "expect 2, got %d", m->len);
        EXPECT(r->x == 1, "expect 1, got %d", r->x);
        EXPECT(r->y == 1, "expect 1, got %d", r->y);
    }
    {
        room_t* r = hm_get(m, 1, 0);
        EXPECT(m->len == 2, "expect 2, got %d", m->len);
        EXPECT(r->x == 1, "expect 1, got %d", r->x);
        EXPECT(r->y == 0, "expect 1, got %d", r->y);
    }
    hm_deinit(m);
}

TEST(test_furthest_room_impl)
{
    typedef struct {
        const char* route;
        i32 expect;
    } test_case;

    const test_case test_cases[] = {
        {"^WNE$", 3},
        {"^ENWWW(NEEE|SSE(EE|N))$", 10},
        {"^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$", 18},
        {"^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$", 23},
        {"^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$",
         31},
    };

    for (u64 i = 0; i < sizeof(test_cases) / sizeof(test_case); i++) {
        test_case tt = test_cases[i];
        i32 got = furthest_room_impl(tt.route);
        EXPECT(got == tt.expect, "expect %d, got %d", tt.expect, got);
    }
}

TEST_MAIN(test_hm, test_furthest_room_impl)

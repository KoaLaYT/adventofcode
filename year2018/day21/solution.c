#include "../lib/kt.h"

#define CAP 65536

i32 fewest_r0(const char* input_file)
{
    UNUSED(input_file);

    i64 r5 = 0;
    i64 r3 = r5 | 65536;
    r5 = 9010242;

    for (;;) {
        i64 r1 = r3 & 255;
        r5 += r1;
        r5 = r5 & 16777215;
        r5 *= 65899;
        r5 = r5 & 16777215;

        if (r3 < 256) {
            return r5;
        }

        r1 = 0;
        for (;;) {
            i64 r4 = r1 + 1;
            r4 = r4 * 256;

            if (r4 > r3) {
                r3 = r1;
                break;
            }

            r1 += 1;
        }
    }
}

static b8 has_seen(i64* seen, i32 len, i64 v)
{
    for (i32 i = 0; i < len; i++) {
        if (seen[i] == v) return TRUE;
    }
    return FALSE;
}

i32 most_r0(const char* input_file)
{
    UNUSED(input_file);

    void* arena = kt_linear_arena_init(sizeof(i64) * CAP);

    i64* seen = kt_linear_arena_array(arena, i64, CAP);
    i32 len = 0;

    i64 r5 = 0;

    for (;;) {
        i64 r3 = r5 | 65536;
        r5 = 9010242;

        for (;;) {
            i64 r1 = r3 & 255;
            r5 += r1;
            r5 = r5 & 16777215;
            r5 *= 65899;
            r5 = r5 & 16777215;

            if (r3 < 256) {
                if (has_seen(seen, len, r5)) {
                    return seen[len - 1];
                }
                ASSERT_MSG(len < CAP, "overflow %d", len);
                seen[len++] = r5;
                break;
            }

            r3 /= 256;
        }
    }
}

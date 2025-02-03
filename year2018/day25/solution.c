#include "../lib/kt.h"
#include "../lib/re.h"

#define ABS(a) ((a) < 0 ? -(a) : (a))

typedef struct {
    i32 x, y, z, w;
} point_t;

typedef struct {
    point_t* data;
    i32 len;
} points_t;

static point_t point_from(const char* s)
{
    re_t pattern = re_compile("-?\\d+");
    int len;

    int vs[4];
    for (int i = 0; i < 4; i++) {
        s += re_matchp(pattern, s, &len);
        vs[i] = kt_atoi_s(s, len);
        s += len;
    }

    point_t p;
    p.x = vs[0];
    p.y = vs[1];
    p.z = vs[2];
    p.w = vs[3];
    return p;
}

static points_t points_from(void* arena, const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);
    const char* line;
    i32 len = 0;

    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        len += 1;
    }
    kt_scanner_reset(scanner);

    point_t* data = kt_linear_arena_array_zero(arena, point_t, len);
    len = 0;

    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        data[len++] = point_from(line);
    }
    kt_scanner_deinit(scanner);

    points_t ps;
    ps.data = data;
    ps.len = len;
    return ps;
}

static b8 point_connected(point_t p1, point_t p2)
{
    i32 dist = ABS(p1.x - p2.x) + ABS(p1.y - p2.y) + ABS(p1.z - p2.z) +
               ABS(p1.w - p2.w);
    return dist <= 3;
}

static b8 includes(i32* vs, i32 len, i32 target)
{
    for (i32 i = 0; i < len; i++) {
        if (vs[i] == target) return TRUE;
    }
    return FALSE;
}

static i32 count_constellations_impl(void* arena, points_t ps)
{
    i32* rels = kt_linear_arena_array_zero(arena, i32, ps.len);

    i32* temp = kt_linear_arena_array_zero(arena, i32, ps.len);
    i32 len = 0;

    for (i32 i = 0; i < ps.len; i++) {
        len = 0;
        for (i32 j = 0; j < i; j++) {
            if (point_connected(ps.data[i], ps.data[j])) {
                temp[len++] = rels[j];
            }
        }
        if (len == 0) rels[i] = i;
        if (len >= 1) {
            i32 rel = temp[0];
            while (rels[rel] != rel) {
                rel = rels[rel];
            }
            rels[i] = rel;
        }
        if (len >= 2) {
            for (i32 j = 0; j < i; j++) {
                if (includes(temp, len, rels[j])) {
                    rels[j] = temp[0];
                }
            }
        }
    }

    i32 count = 0;
    for (i32 i = 0; i < ps.len; i++) {
        b8 dup = FALSE;
        for (i32 j = 0; j < i; j++) {
            if (rels[i] == rels[j]) {
                dup = TRUE;
                break;
            }
        }
        if (!dup) count += 1;
    }
    return count;
}

i32 count_constellations(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    points_t ps = points_from(arena, input_file);
    i32 result = count_constellations_impl(arena, ps);
    kt_linear_arena_deinit(arena);
    return result;
}

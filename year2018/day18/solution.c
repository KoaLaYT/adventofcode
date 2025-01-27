#include "../lib/kt.h"

#define CHAR_OPEN '.'
#define CHAR_TREE '|'
#define CHAR_YARD '#'

typedef struct {
    char* acres;
    char* buf;
    i32 width, height;
} lumber_t;

typedef struct {
    const char* output;
    i32 trees, yards;
} record_t;

#define NDEBUG
#ifdef NDEBUG
#define DEBUG_LUMBER(l)
#else
#define DEBUG_LUMBER(l)                                 \
    {                                                   \
        for (i32 y = 0; y < l.height; y++) {            \
            for (i32 x = 0; x < l.width; x++) {         \
                printf("%c", l.acres[y * l.width + x]); \
            }                                           \
            printf("\n");                               \
        }                                               \
        printf("\n");                                   \
    }
#endif

static b8 record_equal(record_t r1, record_t r2)
{
    if (r1.trees != r2.trees) return FALSE;
    if (r1.yards != r2.yards) return FALSE;
    return strcmp(r1.output, r2.output) == 0;
}

static const char* lumber_stringify(void* arena, const lumber_t* l)
{
    char* output =
        kt_linear_arena_array_zero(arena, char, l->width * l->height + 1);
    for (i32 i = 0; i < l->width * l->height; i++) {
        output[i] = l->acres[i];
    }
    return output;
}

static lumber_t lumber_init(void* arena, const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);
    const char* line;

    i32 width = 0, height = 0;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        width = strlen(line);
        height += 1;
    }
    kt_scanner_reset(scanner);

    ASSERT_MSG(width == height, "not a square, got %dx%d", width, height);
    char* acres = kt_linear_arena_array(arena, char, width* height);
    char* buf = kt_linear_arena_array(arena, char, width* height);
    i32 y = 0;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        for (i32 x = 0; x < width; x++) {
            acres[y * width + x] = line[x];
        }
        y += 1;
    }
    kt_scanner_deinit(scanner);

    lumber_t l;
    l.acres = acres;
    l.buf = buf;
    l.width = width;
    l.height = height;
    return l;
}

static char lumber_acre_at(const lumber_t* l, i32 x, i32 y)
{
    if (x < 0 || x >= l->width || y < 0 || y >= l->height) return 0;
    return l->acres[y * l->width + x];
}

static void lumber_acre_adjacent(const lumber_t* l, i32 x, i32 y, char* adj)
{
    adj[0] = lumber_acre_at(l, x - 1, y - 1);
    adj[1] = lumber_acre_at(l, x, y - 1);
    adj[2] = lumber_acre_at(l, x + 1, y - 1);

    adj[3] = lumber_acre_at(l, x - 1, y);
    adj[4] = lumber_acre_at(l, x + 1, y);

    adj[5] = lumber_acre_at(l, x - 1, y + 1);
    adj[6] = lumber_acre_at(l, x, y + 1);
    adj[7] = lumber_acre_at(l, x + 1, y + 1);
}

static void lumber_change_open(lumber_t* l, i32 x, i32 y)
{
    char adj[8];
    lumber_acre_adjacent(l, x, y, adj);

    i32 trees = 0;
    for (i32 i = 0; i < 8; i++) {
        if (adj[i] == CHAR_TREE) {
            trees += 1;
        }
    }

    l->buf[y * l->width + x] = trees >= 3 ? CHAR_TREE : CHAR_OPEN;
}

static void lumber_change_tree(lumber_t* l, i32 x, i32 y)
{
    char adj[8];
    lumber_acre_adjacent(l, x, y, adj);

    i32 yards = 0;
    for (i32 i = 0; i < 8; i++) {
        if (adj[i] == CHAR_YARD) {
            yards += 1;
        }
    }

    l->buf[y * l->width + x] = yards >= 3 ? CHAR_YARD : CHAR_TREE;
}

static void lumber_change_yard(lumber_t* l, i32 x, i32 y)
{
    char adj[8];
    lumber_acre_adjacent(l, x, y, adj);

    i32 yards = 0;
    i32 trees = 0;
    for (i32 i = 0; i < 8; i++) {
        if (adj[i] == CHAR_YARD) {
            yards += 1;
        }
        if (adj[i] == CHAR_TREE) {
            trees += 1;
        }
    }

    l->buf[y * l->width + x] =
        (yards >= 1 && trees >= 1) ? CHAR_YARD : CHAR_OPEN;
}

static void lumber_change(lumber_t* l)
{
    for (i32 y = 0; y < l->height; y++) {
        for (i32 x = 0; x < l->width; x++) {
            i32 idx = y * l->width + x;
            char c = l->acres[idx];
            switch (c) {
                case CHAR_OPEN:
                    lumber_change_open(l, x, y);
                    break;
                case CHAR_TREE:
                    lumber_change_tree(l, x, y);
                    break;
                case CHAR_YARD:
                    lumber_change_yard(l, x, y);
                    break;
            }
        }
    }

    char* temp = l->acres;
    l->acres = l->buf;
    l->buf = temp;
}

static i32 lumber_count(const lumber_t* l, char c)
{
    i32 count = 0;
    for (i32 y = 0; y < l->height; y++) {
        for (i32 x = 0; x < l->width; x++) {
            if (l->acres[y * l->width + x] == c) {
                count += 1;
            }
        }
    }
    return count;
}

static i32 try_find_loop(const record_t* records, i32 len)
{
    i32 last_idx = len - 1;
    record_t t = records[last_idx];

    for (i32 i = 0; i < last_idx; i++) {
        record_t r = records[i];
        if (record_equal(r, t)) {
            return i;
        }
    }

    return -1;
}

i32 resources(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    lumber_t l = lumber_init(arena, input_file);
    for (i32 round = 0; round < 10; round++) {
        lumber_change(&l);
        DEBUG_LUMBER(l);
    }
    i32 trees = lumber_count(&l, CHAR_TREE);
    i32 yards = lumber_count(&l, CHAR_YARD);
    i32 result = trees * yards;
    kt_linear_arena_deinit(arena);
    return result;
}

i32 resources2(const char* input_file)
{
    void* arena = kt_linear_arena_init(2 * 1024 * 1024);
    lumber_t l = lumber_init(arena, input_file);
    record_t* records = kt_linear_arena_array(arena, record_t, 1024);

    i32 round = 0;
    i32 total = 1000000000;
    i32 loop = 0;
    for (; round < total; round++) {
        assert(round < 1024);

        lumber_change(&l);
        records[round].output = lumber_stringify(arena, &l);
        records[round].trees = lumber_count(&l, CHAR_TREE);
        records[round].yards = lumber_count(&l, CHAR_YARD);

        i32 found = try_find_loop(records, round + 1);
        if (found >= 0) {
            loop = round - found;
            break;
        }
    }

    i32 left = (total - round - 1) % loop;
    for (i32 i = 0; i < left; i++) {
        lumber_change(&l);
    }
    i32 trees = lumber_count(&l, CHAR_TREE);
    i32 yards = lumber_count(&l, CHAR_YARD);
    i32 result = trees * yards;

    kt_linear_arena_deinit(arena);

    return result;
}

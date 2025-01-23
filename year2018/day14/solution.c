#include "../lib/kt.h"

#define CAP (32 * 1024 * 1024)

static int create_new_recipes(int v, char* arr, int len)
{
    if (v < 10) {
        arr[len] = v + '0';
        return len + 1;
    }

    int v1 = v / 10;
    int v2 = v % 10;
    arr[len] = v1 + '0';
    arr[len + 1] = v2 + '0';
    return len + 2;
}

static const char* ten_recipes_impl(void* arena, int recipes)
{
    char* arr = kt_linear_arena_array(arena, char, recipes + 10 + 2);
    arr[0] = '3';
    arr[1] = '7';
    int len = 2;
    int fst = 0, snd = 1;

    while (len < recipes + 10) {
        char c1 = arr[fst];
        char c2 = arr[snd];
        int v1 = c1 - '0';
        int v2 = c2 - '0';
        len = create_new_recipes(v1 + v2, arr, len);
        fst = (fst + 1 + v1) % len;
        snd = (snd + 1 + v2) % len;
    }

    char* num = kt_malloc(11);
    for (int i = 0; i < 10; i++) {
        num[i] = arr[recipes + i];
    }
    num[10] = 0;
    return num;
}

static int find_recipes(char* arr, int len, const char* target, int target_len)
{
    if (len < target_len) return -1;
    for (int i = 0; i < target_len; i++) {
        if (target[target_len - i - 1] != arr[len - i - 1]) return -1;
    }
    return len - target_len;
}

static int recipes_until_impl(void* arena, const char* target)
{
    int target_len = strlen(target);
    char* arr = kt_linear_arena_array(arena, char, CAP);
    arr[0] = '3';
    arr[1] = '7';
    int len = 2;
    int fst = 0, snd = 1;

    for (;;) {
        char c1 = arr[fst];
        char c2 = arr[snd];
        int v1 = c1 - '0';
        int v2 = c2 - '0';
        int prev_len = len;
        len = create_new_recipes(v1 + v2, arr, len);
        assert(len < CAP);
        fst = (fst + 1 + v1) % len;
        snd = (snd + 1 + v2) % len;

        int idx = find_recipes(arr, len, target, target_len);
        if (idx >= 0) {
            return idx;
        }
        if (len - prev_len == 2) {
            int idx = find_recipes(arr, len - 1, target, target_len);
            if (idx >= 0) {
                return idx;
            }
        }
    }
}

const char* ten_recipes(const char* input_file)
{
    UNUSED(input_file);
    void* arena = kt_linear_arena_init(10 * 1024 * 1024);
    const char* result = ten_recipes_impl(arena, 509671);
    kt_linear_arena_deinit(arena);
    return result;
}

int recipes_until(const char* input_file)
{
    UNUSED(input_file);
    void* arena = kt_linear_arena_init(CAP);
    int result = recipes_until_impl(arena, "509671");
    kt_linear_arena_deinit(arena);
    return result;
}

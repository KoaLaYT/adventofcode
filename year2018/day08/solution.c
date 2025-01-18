#include "../lib/kt.h"

typedef struct {
    int* arr;
    int len;
} context_t;

static int metadata_sum_impl_recursive(int* arr, int len, int idx, int* sum)
{
    if (idx >= len) return len;

    int childrens = arr[idx];
    int metadatas = arr[idx + 1];

    int next_idx = idx + 2;
    for (int i = 0; i < childrens; i++) {
        next_idx = metadata_sum_impl_recursive(arr, len, next_idx, sum);
    }

    for (int i = 0; i < metadatas; i++) {
        *sum += arr[next_idx];
        next_idx += 1;
    }

    return next_idx;
}

static int metadata_sum_impl(int* arr, int len)
{
    int sum = 0;
    metadata_sum_impl_recursive(arr, len, 0, &sum);
    return sum;
}

static int node_value_impl_recursive(void* arena,                 //
                                     int* arr, int len, int idx,  //
                                     int* value)                  //
{
    if (idx >= len) return 0;

    int childrens = arr[idx];
    int metadatas = arr[idx + 1];

    if (childrens == 0) {
        for (int i = 0; i < metadatas; i++) {
            *value += arr[idx + 2 + i];
        }
        return idx + 2 + metadatas;
    }

    int* child_values = kt_linear_arena_array(arena, int, childrens);
    int next_idx = idx + 2;
    for (int i = 0; i < childrens; i++) {
        next_idx = node_value_impl_recursive(arena,               //
                                             arr, len, next_idx,  //
                                             child_values + i);
    }

    for (int i = 0; i < metadatas; i++) {
        int child_idx = arr[next_idx] - 1;
        if (child_idx >= 0 && child_idx < childrens) {
            *value += child_values[child_idx];
        }
        next_idx += 1;
    }

    return next_idx;
}

static int node_value_impl(void* arena, int* arr, int len)
{
    int value = 0;
    node_value_impl_recursive(arena, arr, len, 0, &value);
    return value;
}

static context_t context_init(void* arena, const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);
    const char* num;
    int len = 0;
    while ((num = kt_scanner_next(scanner, ' ')) != 0) {
        len += 1;
    }

    int* arr = kt_linear_arena_array(arena, int, len);
    len = 0;
    kt_scanner_reset(scanner);
    while ((num = kt_scanner_next(scanner, ' ')) != 0) {
        arr[len++] = kt_atoi(num);
    }
    kt_scanner_deinit(scanner);

    context_t ctx;
    ctx.arr = arr;
    ctx.len = len;
    return ctx;
}

int metadata_sum(const char* input_file)
{
    void* arena = kt_linear_arena_init(1 * 1024 * 1024);
    context_t ctx = context_init(arena, input_file);

    int result = metadata_sum_impl(ctx.arr, ctx.len);

    kt_linear_arena_deinit(arena);

    return result;
}

int node_value(const char* input_file)
{
    void* arena = kt_linear_arena_init(1 * 1024 * 1024);
    context_t ctx = context_init(arena, input_file);

    int result = node_value_impl(arena, ctx.arr, ctx.len);

    kt_linear_arena_deinit(arena);

    return result;
}

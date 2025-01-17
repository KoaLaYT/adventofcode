#include "kt.h"

typedef struct {
    int len;
    int pos;
} linear_arean_t;

void* kt_linear_arena_init(size_t size)
{
    void* m = kt_malloc(size + sizeof(linear_arean_t));

    linear_arean_t* header = (linear_arean_t*)m;
    header->len = size;
    header->pos = 0;

    return header + 1;
}

void* kt_linear_arena_malloc(void* self, size_t size)
{
    linear_arean_t* header = (linear_arean_t*)self - 1;
    int pos = header->pos + size;

    if (pos > header->len) {
        fprintf(stderr, "linear arena out of boundary");
        exit(1);
    }

    void* m = (char*)self + header->pos;
    header->pos = pos;
    return m;
}

void* kt_linear_arena_malloc_zero(void* self, size_t size)
{
    void* m = kt_linear_arena_malloc(self, size);
    memset(m, 0, size);
    return m;
}

void kt_linear_arena_deinit(void* self)
{
    linear_arean_t* header = (linear_arean_t*)self - 1;
    free(header);
}

#pragma once

#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// types
typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;

typedef signed char i8;
typedef signed short i16;
typedef signed int i32;
typedef signed long long i64;

typedef float f32;
typedef double f64;

typedef char b8;
#define TRUE 1
#define FALSE 0

// assert
#define ASSERT_MSG(condition, format, ...)                       \
    do {                                                         \
        if (!(condition)) {                                      \
            fprintf(stderr,                                      \
                    "Assertion failed: %s, file %s, line "       \
                    "%d:\n>>>>>>>>>>>>>>>>: ",                   \
                    #condition, __FILE__, __LINE__);             \
            fprintf(stderr, format, __VA_ARGS__);                \
            fprintf(stderr, "\n"); /* Add newline for clarity */ \
            abort();                                             \
        }                                                        \
    } while (0)

// arena
void* kt_linear_arena_init(int size);
void* kt_linear_arena_malloc(void* self, int size);
void* kt_linear_arena_malloc_zero(void* self, int size);
void kt_linear_arena_deinit(void* self);
#define kt_linear_arena_create(arena, T) \
    (T*)kt_linear_arena_malloc(arena, sizeof(T))
#define kt_linear_arena_create_zero(arena, T) \
    (T*)kt_linear_arena_malloc_zero(arena, sizeof(T))
#define kt_linear_arena_array(arena, T, size) \
    (T*)kt_linear_arena_malloc(arena, sizeof(T) * size);
#define kt_linear_arena_array_zero(arena, T, size) \
    (T*)kt_linear_arena_malloc_zero(arena, sizeof(T) * size);

// io
void* kt_scanner_init(const char* filename);
void kt_scanner_deinit(void* self);
const char* kt_scanner_next(void* self, char delimiter);
void kt_scanner_reset(void* self);
char* kt_read_all(const char* filename);

// util
#define UNUSED(x) (void)(x)

void solve_i(const char* label, const char* input,
             int (*solution)(const char* input));

void solve_s(const char* label, const char* input,
             const char* (*solution)(const char* input));

void solve_l(const char* label, const char* input,
             long (*solution)(const char* input));

#define PART_ONE(solution)                    \
    static void part_one(const char* input)   \
    {                                         \
        solve_i("Part One", input, solution); \
    }

#define PART_ONE_S(solution)                  \
    static void part_one(const char* input)   \
    {                                         \
        solve_s("Part One", input, solution); \
    }

#define PART_ONE_L(solution)                  \
    static void part_one(const char* input)   \
    {                                         \
        solve_l("Part One", input, solution); \
    }

#define PART_TWO(solution)                    \
    static void part_two(const char* input)   \
    {                                         \
        solve_i("Part Two", input, solution); \
    }

#define PART_TWO_S(solution)                  \
    static void part_two(const char* input)   \
    {                                         \
        solve_s("Part Two", input, solution); \
    }

#define PART_TWO_L(solution)                  \
    static void part_two(const char* input)   \
    {                                         \
        solve_l("Part Two", input, solution); \
    }

#define MAIN                        \
    int main(int argc, char** argv) \
    {                               \
        (void)argc;                 \
        char* input = argv[1];      \
        part_one(input);            \
        part_two(input);            \
        return 0;                   \
    }

int kt_atoi(const char* s);
int kt_atoi_s(const char* s, int len);

void* kt_malloc(int size);

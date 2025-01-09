#pragma once

#include "stddef.h"

void solve(const char* label, const char* input,
           int (*solution)(const char* input));

void solve_s(const char* label, const char* input,
             const char* (*solution)(const char* input));

#define PART_ONE(solution)                  \
    static void part_one(const char* input) \
    {                                       \
        solve("Part One", input, solution); \
    }

#define PART_ONE_S(solution)                  \
    static void part_one(const char* input)   \
    {                                         \
        solve_s("Part One", input, solution); \
    }

#define PART_TWO(solution)                  \
    static void part_two(const char* input) \
    {                                       \
        solve("Part Two", input, solution); \
    }

#define PART_TWO_S(solution)                  \
    static void part_two(const char* input)   \
    {                                         \
        solve_s("Part Two", input, solution); \
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

void* kt_malloc(size_t size);

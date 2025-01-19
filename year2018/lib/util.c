#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "kt.h"

static double get_cputime_ms(long res)
{
    struct timespec tp;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &tp);
    return tp.tv_sec * 1000 + tp.tv_nsec * res / 1e6;
}

#define SOLVE(type, suffix)                                         \
    static type solve_##suffix(double* took, const char* input,     \
                               type (*solution)(const char* input)) \
    {                                                               \
        if (solution == 0) return (type)0;                          \
                                                                    \
        struct timespec tp;                                         \
        clock_getres(CLOCK_PROCESS_CPUTIME_ID, &tp);                \
        long res = tp.tv_nsec;                                      \
                                                                    \
        double start = get_cputime_ms(res);                         \
        type result = solution(input);                              \
        double end = get_cputime_ms(res);                           \
                                                                    \
        *took = end - start;                                        \
        return result;                                              \
    }

SOLVE(int, int)
SOLVE(long, long)
SOLVE(const char*, str)

#undef SOLVE

void solve_l(const char* label, const char* input,
             long (*solution)(const char* input))
{
    printf(">>>> %s <<<<\n", label);
    double took;
    long result = solve_long(&took, input, solution);
    printf("Answer: %ld\n", result);
    printf("Took: %.2fms\n", took);
}

void solve_i(const char* label, const char* input,
             int (*solution)(const char* input))
{
    printf(">>>> %s <<<<\n", label);
    double took;
    int result = solve_int(&took, input, solution);
    printf("Answer: %d\n", result);
    printf("Took: %.2fms\n", took);
}

void solve_s(const char* label, const char* input,
             const char* (*solution)(const char* input))
{
    printf(">>>> %s <<<<\n", label);
    double took;
    const char* result = solve_str(&took, input, solution);

    printf("Answer: %s\n", result);
    printf("Took: %.2fms\n", took);

    free((void*)result);
}

int kt_atoi(const char* s)
{
    int i = 0;
    int sign = 1;

    if (s[i] == '+') {
        i += 1;
    } else if (s[i] == '-') {
        i += 1;
        sign = -1;
    }

    int result = 0;
    while (s[i] >= '0' && s[i] <= '9') {
        // TODO overflow check
        result = result * 10 + (s[i] - '0');
        i += 1;
    }

    return result * sign;
}

int kt_atoi_s(const char* s, int len)
{
    int i = 0;
    int sign = 1;

    if (s[i] == '+') {
        i += 1;
    } else if (s[i] == '-') {
        i += 1;
        sign = -1;
    }

    int result = 0;
    while (i < len) {
        // TODO overflow check
        result = result * 10 + (s[i] - '0');
        i += 1;
    }

    return result * sign;
}

void* kt_malloc(size_t size)
{
    void* m = malloc(size);
    if (!m) {
        fprintf(stderr, "malloc failed\n");
        exit(1);
    }
    return m;
}

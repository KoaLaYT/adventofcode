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

void solve(const char* label, const char* input,
           int (*solution)(const char* input))
{
    if (solution == 0) return;

    struct timespec tp;
    clock_getres(CLOCK_PROCESS_CPUTIME_ID, &tp);
    long res = tp.tv_nsec;

    printf(">>>> %s <<<<\n", label);

    double start = get_cputime_ms(res);
    int result = solution(input);
    double end = get_cputime_ms(res);

    printf("Answer: %d\n", result);
    printf("Took: %.2fms\n", end - start);
}

void solve_s(const char* label, const char* input,
             const char* (*solution)(const char* input))
{
    if (solution == 0) return;

    struct timespec tp;
    clock_getres(CLOCK_PROCESS_CPUTIME_ID, &tp);
    long res = tp.tv_nsec;

    printf(">>>> %s <<<<\n", label);

    double start = get_cputime_ms(res);
    const char* result = solution(input);
    double end = get_cputime_ms(res);

    printf("Answer: %s\n", result);
    printf("Took: %.2fms\n", end - start);

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

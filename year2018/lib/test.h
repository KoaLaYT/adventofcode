#pragma once

#include <stddef.h>
#include <stdio.h>
#include <string.h>

#define FILENAME (strrchr("/" __FILE__, '/') + 1)

#define INTERNAL_ASSERT(expr, assert, ...)          \
    do {                                            \
        if (!(expr)) {                              \
            printf("%s:%d - ", FILENAME, __LINE__); \
            printf(__VA_ARGS__);                    \
            printf("\n");                           \
            *test_failed = 1;                       \
            if (assert) return;                     \
        }                                           \
    } while (0)

#define EXPECT(expr, ...) INTERNAL_ASSERT(expr, 0, __VA_ARGS__)
#define ASSERT(expr, ...) INTERNAL_ASSERT(expr, 1, __VA_ARGS__)

typedef struct {
    void (*fn)(int *);
    char *name;
} TestInfo;

#define TEST(name)                                   \
    static void name##_fn(int *);                    \
    static const TestInfo name = {name##_fn, #name}; \
    static void name##_fn(int *test_failed)

#define TEST_MAIN(...)                                                  \
    int main(void)                                                      \
    {                                                                   \
        const TestInfo tests[] = {__VA_ARGS__};                         \
        int failed_tests = 0;                                           \
        for (size_t i = 0; i < sizeof(tests) / sizeof(tests[0]); i++) { \
            int test_failed = 0;                                        \
            tests[i].fn(&test_failed);                                  \
            failed_tests += test_failed;                                \
            printf("%s: %s\n",                                          \
                   test_failed ? "\033[0;31mFAILED\033[0m"              \
                               : "\033[0;32mPASSED\033[0m",             \
                   tests[i].name);                                      \
        }                                                               \
        return failed_tests ? 1 : 0;                                    \
    }

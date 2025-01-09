#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../lib/io.h"
#include "../lib/util.h"

static int count_letters(const char* s, int num)
{
    int times[26] = {0};

    const char* c = s;
    while (*c != 0) {
        times[*c - 'a'] += 1;
        c++;
    }

    for (int i = 0; i < 26; i++) {
        if (times[i] == num) {
            return 1;
        }
    }

    return 0;
}

int checksum(const char* input)
{
    int n2 = 0;
    int n3 = 0;

    void* scanner = kt_scanner_init(input);
    const char* line;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        n2 += count_letters(line, 2);
        n3 += count_letters(line, 3);
    }
    kt_scanner_deinit(scanner);

    return n2 * n3;
}

static int diff(const char* s1, const char* s2)
{
    const char* c1 = s1;
    const char* c2 = s2;

    int d = 0;
    while (*c1 != 0 || *c2 != 0) {
        if (*c1 != *c2) {
            d += 1;
        }
        if (*c1 != 0) {
            c1++;
        }
        if (*c2 != 0) {
            c2++;
        }
    }
    return d;
}

static void find_correct_id(const char** ids, int len, int* a, int* b)
{
    for (int i = 0; i < len; i++) {
        for (int j = i + 1; j < len; j++) {
            if (diff(ids[i], ids[j]) == 1) {
                *a = i;
                *b = j;
                return;
            }
        }
    }
}

static const char* copy_id(const char* a, const char* b)
{
    char* result = kt_malloc(strlen(a));
    int i = 0;
    const char* ca = a;
    const char* cb = b;
    while (*ca != 0) {
        if (*ca == *cb) {
            result[i++] = *ca;
        }
        ca++;
        cb++;
    }
    result[i] = '\0';
    return result;
}

const char* correct_id(const char* input)
{
    const char* lines[512];

    void* scanner = kt_scanner_init(input);
    const char* line;
    int len = 0;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        char* buf = kt_malloc(strlen(line) + 1);
        strcpy(buf, line);
        lines[len++] = buf;
    }

    int a, b;
    find_correct_id(lines, len, &a, &b);
    const char* result = copy_id(lines[a], lines[b]);

    kt_scanner_deinit(scanner);
    for (int i = 0; i < len; i++) {
        free((void*)lines[i]);
    }

    return result;
}

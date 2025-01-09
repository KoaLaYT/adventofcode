#include <stdio.h>
#include <stdlib.h>

#include "../lib/io.h"
#include "../lib/util.h"

static int parse_row(const char* s) { return kt_atoi(s); }

int count_frequency(const char* input_file)
{
    int result = 0;

    void* scanner = kt_scanner_init(input_file);
    const char* line;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        result += parse_row(line);
    }
    kt_scanner_deinit(scanner);

    return result;
}

static int pmod(int num, int m)
{
    if (num < 0) {
        return m - (-num) % m;
    }
    return num % m;
}

static void sorted_insert(int* buf, int buf_len, const int* sums, int i)
{
    int inserted = 0;
    for (int j = 0; j < buf_len; j++) {
        if (sums[buf[j]] > sums[i]) {
            for (int k = buf_len + 1; k > j; k--) {
                buf[k] = buf[k - 1];
            }
            buf[j] = i;
            inserted = 1;
            break;
        }
    }

    if (inserted == 0) {
        buf[buf_len] = i;
    }
}

static int find_twice_frequency(const int* arr, int len)
{
    int sum = 0;
    for (int i = 0; i < len; i++) {
        sum += arr[i];
    }

    int* sums = kt_malloc(sizeof(int) * len);
    sums[0] = 0;
    for (int i = 0; i < len - 1; i++) {
        sums[i + 1] = sums[i] + arr[i];
    }

    int* buf = kt_malloc(sizeof(int) * len);
    int min_diff = 2147483647;
    int min_index = len;
    int min_freq = 0;

    for (int mod = 0; mod < sum; mod++) {
        int buf_len = 0;

        for (int i = 0; i < len; i++) {
            if (pmod(sums[i], sum) == mod) {
                sorted_insert(buf, buf_len, sums, i);
                buf_len += 1;
            }
        }

        for (int i = 1; i < buf_len; i++) {
            int a = buf[i - 1];
            int b = buf[i];
            int diff = sums[b] - sums[a];
            if ((diff < min_diff) || (diff == min_diff && a < min_index)) {
                min_diff = diff;
                min_index = a;
                min_freq = sums[b];
            }
        }
    }

    free(sums);
    free(buf);

    return min_freq;
}

int twice_frequency(const char* input_file)
{
    int arr[1024] = {0};
    int len = 0;

    void* scanner = kt_scanner_init(input_file);
    const char* line;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        arr[len++] = parse_row(line);
    }
    kt_scanner_deinit(scanner);

    return find_twice_frequency(arr, len);
}

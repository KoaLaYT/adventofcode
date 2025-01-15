#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../lib/kt.h"
#include "../lib/re.h"

#define MAX(a, b) ((a) > (b) ? (a) : (b))

typedef struct {
    int left;
    int top;
    int width;
    int height;
} claim_t;

static void mark(int width, int* arr, claim_t* claim)
{
    for (int i = claim->top; i < claim->top + claim->height; i++) {
        for (int j = claim->left; j < claim->left + claim->width; j++) {
            arr[i * width + j] += 1;
        }
    }
}

static int count_overlaps(int width, int height, claim_t* claims, int size)
{
    int* arr = kt_malloc(sizeof(int) * width * height);
    memset(arr, 0, sizeof(int) * width * height);

    for (int i = 0; i < size; i++) {
        mark(width, arr, claims + i);
    }

    int overlaps = 0;
    for (int i = 0; i < width * height; i++) {
        if (arr[i] > 1) {
            overlaps += 1;
        }
    }

    free(arr);

    return overlaps;
}

static int is_none_overlap(int width, int* arr, const claim_t* claim)
{
    for (int i = claim->top; i < claim->top + claim->height; i++) {
        for (int j = claim->left; j < claim->left + claim->width; j++) {
            if (arr[i * width + j] > 1) {
                return 0;
            }
        }
    }
    return 1;
}

static int find_none_overlap(int width, int height, claim_t* claims, int size)
{
    int* arr = kt_malloc(sizeof(int) * width * height);
    memset(arr, 0, sizeof(int) * width * height);

    for (int i = 0; i < size; i++) {
        mark(width, arr, claims + i);
    }

    for (int i = 0; i < size; i++) {
        if (is_none_overlap(width, arr, claims + i)) {
            return i + 1;
        }
    }

    free(arr);

    return -1;
}

static void parse_claim(const char* input, claim_t* claim)
{
    int i = 0;
    while (input[i] != '@') i += 1;
    i += 2;

    const char* s = input + i;

    re_t pattern = re_compile("\\d+");
    int len;

    s += re_matchp(pattern, s, &len);
    claim->left = kt_atoi_s(s, len);
    s += len;

    s += re_matchp(pattern, s, &len);
    claim->top = kt_atoi_s(s, len);
    s += len;

    s += re_matchp(pattern, s, &len);
    claim->width = kt_atoi_s(s, len);
    s += len;

    s += re_matchp(pattern, s, &len);
    claim->height = kt_atoi_s(s, len);
}

int overlap_fabrics(const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);

    int width = 0, height = 0, size = 0;
    const char* line;
    claim_t claim;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        parse_claim(line, &claim);
        width = MAX(width, claim.left + claim.width);
        height = MAX(height, claim.top + claim.height);
        size += 1;
    }

    claim_t* claims = kt_malloc(sizeof(claim) * size);
    kt_scanner_reset(scanner);
    int i = 0;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        parse_claim(line, claims + i);
        i += 1;
    }

    kt_scanner_deinit(scanner);

    int result = count_overlaps(width, height, claims, size);

    free(claims);

    return result;
}

int none_overlap_fabric(const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);

    int width = 0, height = 0, size = 0;
    const char* line;
    claim_t claim;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        parse_claim(line, &claim);
        width = MAX(width, claim.left + claim.width);
        height = MAX(height, claim.top + claim.height);
        size += 1;
    }

    claim_t* claims = kt_malloc(sizeof(claim) * size);
    kt_scanner_reset(scanner);
    int i = 0;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        parse_claim(line, claims + i);
        i += 1;
    }

    kt_scanner_deinit(scanner);

    int result = find_none_overlap(width, height, claims, size);

    free(claims);

    return result;
}

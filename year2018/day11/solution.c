#include <stdlib.h>

#include "../lib/kt.h"

#define SIZE 300

typedef struct {
    int x, y;
    int s, v;
} result_t;

static int hundred_digit(int num)
{
    if (num < 100) return 0;
    int v1 = num / 100;
    int v2 = num / 1000;
    return v1 - 10 * v2;
}

static int power_level(int x, int y, int serial_num)
{
    int rack_id = x + 10;
    int result = rack_id * y;
    result += serial_num;
    result *= rack_id;
    result = hundred_digit(result);
    return result - 5;
}

static int* calculate_powers(int serial_num)
{
    int* powers = kt_malloc(sizeof(int) * SIZE * SIZE);

    for (int y = 0; y < SIZE; y++) {
        for (int x = 0; x < SIZE; x++) {
            powers[y * SIZE + x] = power_level(x + 1, y + 1, serial_num);
        }
    }

    return powers;
}

static result_t largest_square_impl(int* powers, int size)
{
    int largest = -2147483647;
    int lx = 0, ly = 0;

    for (int y = 0; y < SIZE - size + 1; y++) {
        for (int x = 0; x < SIZE - size + 1; x++) {
            int v = 0;
            for (int i = 0; i < size; i++) {
                for (int j = 0; j < size; j++) {
                    v += powers[(y + i) * SIZE + x + j];
                }
            }
            if (v > largest) {
                lx = x + 1;
                ly = y + 1;
                largest = v;
            }
        }
    }

    result_t c;
    c.x = lx;
    c.y = ly;
    c.v = largest;
    c.s = size;
    return c;
}

static const char* largest_33_impl(int serial_num)
{
    int* powers = calculate_powers(serial_num);
    result_t c = largest_square_impl(powers, 3);
    free(powers);
    char* result = kt_malloc(8);
    memset(result, 0, 8);
    sprintf(result, "%d,%d", c.x, c.y);
    return result;
}

static const char* largest_impl(int serial_num)
{
    int* powers = calculate_powers(serial_num);
    result_t largest = {0};
    largest.v = -2147483647;
    for (int size = 1; size <= SIZE; size++) {
        result_t r = largest_square_impl(powers, size);
        if (r.v < 0) break;
        if (r.v > largest.v) {
            largest = r;
        }
    }
    free(powers);
    char* result = kt_malloc(12);
    memset(result, 0, 12);
    sprintf(result, "%d,%d,%d", largest.x, largest.y, largest.s);
    return result;
}

const char* largest_33(const char* input_file)
{
    UNUSED(input_file);
    return largest_33_impl(9221);
}

const char* largest(const char* input_file)
{
    UNUSED(input_file);
    return largest_impl(9221);
}

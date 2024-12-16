#include <stdio.h>
#include <stdlib.h>
#define LIST_SIZE 256

static void reverse(int* list, int list_size, int len, int p)
{
    int i = p;
    int j = (p + len - 1) % list_size;
    int step = len / 2;

    while (step > 0) {
        int tmp = list[i];
        list[i] = list[j];
        list[j] = tmp;

        i = (i + 1) % list_size;
        j = (j - 1 + list_size) % list_size;
        step -= 1;
    }
}

const char* full_knot_hash(const char* input, int len)
{
    int list[LIST_SIZE];
    for (int i = 0; i < LIST_SIZE; i++) {
        list[i] = i;
    }

    int p = 0;  // current position
    int s = 0;  // skip size

    for (int round = 0; round < 64; round++) {
        for (int i = 0; i < len; i++) {
            int l = input[i];
            reverse(list, LIST_SIZE, l, p);
            p = (p + l + s) % LIST_SIZE;
            s += 1;
        }
    }

    char* hash = (char*)malloc(129);
    for (int block = 0; block < 16; block++) {
        int val = 0;
        for (int i = 0; i < 16; i++) {
            val ^= list[block * 16 + i];
        }
        for (int i = 0, z = 128; z > 0; i += 1, z >>= 1) {
            sprintf(hash + 8 * block + i, "%s", (val & z) == z ? "1" : "0");
        }
    }
    hash[128] = '\0';
    return hash;
}

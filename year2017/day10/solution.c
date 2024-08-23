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

int knot_hash(int* input, int len, int list_size)
{
    int list[list_size];
    for (int i = 0; i < list_size; i++) {
        list[i] = i;
    }

    int p = 0;  // current position
    int s = 0;  // skip size

    for (int i = 0; i < len; i++) {
        int l = input[i];
        reverse(list, list_size, l, p);
        p = (p + l + s) % list_size;
        s += 1;
    }

    return list[0] * list[1];
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

    char* hash = (char*)malloc(33);
    for (int block = 0; block < 16; block++) {
        int val = 0;
        for (int i = 0; i < 16; i++) {
            val ^= list[block * 16 + i];
        }
        sprintf(hash + 2 * block, "%02x", val);
    }
    hash[32] = '\0';
    return hash;
}

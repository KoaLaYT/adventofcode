#include "../lib/kt.h"
#define DIFF 32

static int find_left(const char* polymer, int i)
{
    for (int j = i - 1; j >= 0; j--) {
        if (polymer[j] != 0) {
            return j;
        }
    }
    return -1;
}

static int is_opposite(const char* polymer, int i, int j)
{
    int diff = polymer[i] - polymer[j];
    if (diff < 0) diff = -diff;
    return diff == DIFF;
}

static int remain_after_reaction(char* polymer, int len)
{
    int remain = 0;

    for (int i = 0; i < len; i++) {
        if (polymer[i] == 0) continue;
        remain += 1;

        int left = find_left(polymer, i);
        if (left >= 0 && is_opposite(polymer, left, i)) {
            polymer[left] = 0;
            polymer[i] = 0;
            remain -= 2;
        }
    }

    return remain;
}

static void shorten(char* polymer, int len, char* buf, int* buf_len)
{
    remain_after_reaction(polymer, len);
    for (int i = 0; i < len; i++) {
        if (polymer[i] == 0) continue;
        buf[*buf_len] = polymer[i];
        *buf_len += 1;
    }
    buf[*buf_len] = 0;
}

static void remove_units(char* s, int len, char a, char b)
{
    for (int i = 0; i < len; i++) {
        if (s[i] == a || s[i] == b) {
            s[i] = 0;
        }
    }
}

static int find_shortest(char* polymer)
{
    int len = strlen(polymer);
    char* shorted = kt_malloc(2 * (len + 1));

    int buf_len = 0;
    shorten(polymer, len, shorted, &buf_len);
    char* buf = shorted + len + 1;

    int shortest = buf_len;
    for (int i = 0; i < 26; i++) {
        strcpy(buf, shorted);
        remove_units(buf, buf_len, 'a' + i, 'A' + i);
        int remain = remain_after_reaction(buf, buf_len);
        if (remain < shortest) {
            shortest = remain;
        }
    }

    free(shorted);
    return shortest;
}

int remain_units(const char* input_file)
{
    char* s = kt_read_all(input_file);
    int result = remain_after_reaction(s, strlen(s));
    free(s);
    return result;
}

int shortest(const char* input_file)
{
    char* s = kt_read_all(input_file);
    int result = find_shortest(s);
    free(s);
    return result;
}

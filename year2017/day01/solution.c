int count_sum(const char* str, int len)
{
    int sum = 0;

    for (int i = 0; i < len; i++) {
        int j = i + 1;
        if (j >= len) {
            j = 0;
        }
        if (str[i] == str[j]) {
            sum += str[i] - '0';
        }
    }

    return sum;
}

int count_sum_v2(const char* str, int len)
{
    int sum = 0;
    int half = len / 2;

    for (int i = 0; i < half; i++) {
        if (str[i] == str[i + half]) {
            sum += str[i] - '0';
        }
    }

    return sum * 2;
}

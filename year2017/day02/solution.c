int differences(const int* row, int len)
{
    int min = row[0];
    int max = row[0];

    for (int i = 1; i < len; i++) {
        int v = row[i];
        if (v < min) {
            min = v;
        }
        if (v > max) {
            max = v;
        }
    }

    return max - min;
}

int division(const int* row, int len)
{
    for (int i = 0; i < len; i++) {
        for (int j = i + 1; j < len; j++) {
            int v1 = row[i];
            int v2 = row[j];
            if (v1 % v2 == 0) {
                return v1 / v2;
            }
            if (v2 % v1 == 0) {
                return v2 / v1;
            }
        }
    }
    return -1;
}

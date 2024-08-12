int jump_steps(int* list, int len)
{
    int i = 0;
    int step = 0;

    while (i >= 0 && i < len) {
        int v = list[i];
        list[i] += 1;
        i += v;
        step += 1;
    }

    return step;
}

int jump_steps_v2(int* list, int len)
{
    int i = 0;
    int step = 0;

    while (i >= 0 && i < len) {
        int v = list[i];
        if (v >= 3) {
            list[i] -= 1;
        } else {
            list[i] += 1;
        }
        i += v;
        step += 1;
    }

    return step;
}

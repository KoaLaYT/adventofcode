typedef int bool;

#define TRUE 1
#define FALSE 0

static int do_group_score(const char* s, int idx, int len, int level,
                          int* end_idx)
{
    int score = level;

    bool in_garbage = FALSE;
    idx += 1;  // s[idx] == '{'

    while (idx < len) {
        if (s[idx] == '!') {
            idx += 2;
            continue;
        }

        if (in_garbage) {
            if (s[idx] == '>') {
                in_garbage = FALSE;
            }
            idx += 1;
            continue;
        }

        if (s[idx] == '<') {
            in_garbage = TRUE;
            idx += 1;
            continue;
        }

        if (s[idx] == '}') {
            idx += 1;
            break;
        }

        if (s[idx] == '{') {
            int end_idx;
            score += do_group_score(s, idx, len, level + 1, &end_idx);
            idx = end_idx;
            continue;
        }

        idx += 1;
    }

    if (end_idx) {
        *end_idx = idx;
    }
    return score;
}

int group_score(const char* s, int len)
{
    return do_group_score(s, 0, len, 1, 0);
}

static int do_count_garbage(const char* s, int idx, int len, int* end_idx)
{
    int count = 0;

    bool in_garbage = FALSE;
    idx += 1;

    while (idx < len) {
        if (s[idx] == '!') {
            idx += 2;
            continue;
        }

        if (in_garbage) {
            if (s[idx] == '>') {
                in_garbage = FALSE;
            } else {
                count += 1;
            }
            idx += 1;
            continue;
        }

        if (s[idx] == '<') {
            in_garbage = TRUE;
            idx += 1;
            continue;
        }

        if (s[idx] == '}') {
            idx += 1;
            break;
        }

        if (s[idx] == '{') {
            int end_idx;
            count += do_count_garbage(s, idx, len, &end_idx);
            idx = end_idx;
            continue;
        }

        idx += 1;
    }

    if (end_idx) {
        *end_idx = idx;
    }
    return count;
}

int count_garbage(const char* s, int len)
{
    return do_count_garbage(s, 0, len, 0);
}

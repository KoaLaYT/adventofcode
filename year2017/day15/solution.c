#define FACTOR_A (long)16807
#define MULTI_A 3
#define FACTOR_B (long)48271
#define MULTI_B 7
#define MOD 2147483647
#define V 65535

static int produce(int v, long factor, int multi)
{
    while (1) {
        v = (int)((v * factor) % MOD);
        if ((v & multi) == 0) {
            return v;
        }
    }
}

int judge_count(int start_a, int start_b, int round)
{
    int pa = start_a;
    int pb = start_b;
    int count = 0;
    for (int i = 0; i < round; i++) {
        pa = (int)((pa * FACTOR_A) % MOD);
        pb = (int)((pb * FACTOR_B) % MOD);

        if ((pa & V) == (pb & V)) {
            count += 1;
        }
    }
    return count;
}

int judge_count2(int start_a, int start_b, int round)
{
    int pa = start_a;
    int pb = start_b;
    int count = 0;
    for (int i = 0; i < round; i++) {
        pa = produce(pa, FACTOR_A, MULTI_A);
        pb = produce(pb, FACTOR_B, MULTI_B);

        if ((pa & V) == (pb & V)) {
            count += 1;
        }
    }
    return count;
}

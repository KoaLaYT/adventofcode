#include "../lib/kt.h"

typedef struct {
    char step;
    char deps;
} requirement_t;

typedef struct {
    requirement_t* rs;
    int len;
} context_t;

typedef struct {
    char step;
    int left;
} worker_t;

static void requirement_from(const char* s, requirement_t* r)
{
    int i = 1;
    while (s[i]) {
        if ('A' <= s[i] && s[i] <= 'Z') {
            r->deps = s[i];
            break;
        }
        i += 1;
    }

    i += 1;
    while (s[i]) {
        if ('A' <= s[i] && s[i] <= 'Z') {
            r->step = s[i];
            break;
        }
        i += 1;
    }
}

static int total_steps(const requirement_t* rs, int len)
{
    int steps[26] = {0};
    for (int i = 0; i < len; i++) {
        steps[rs[i].step - 'A'] += 1;
        steps[rs[i].deps - 'A'] += 1;
    }

    int total = 0;
    for (int i = 0; i < 26; i++) {
        if (steps[i] > 0) {
            total += 1;
        }
    }
    return total;
}

static void update_deps(const requirement_t* rs, int len, int* deps, int* coms)
{
    for (int i = 0; i < len; i++) {
        if (coms[rs[i].deps - 'A'] == 1) continue;
        deps[rs[i].step - 'A'] += 1;
    }
}

static char doable_step(int* deps, int* com, int total, int instant_finish)
{
    for (int i = 0; i < total; i++) {
        if (deps[i] == 0 && com[i] == 0) {
            if (instant_finish) {
                com[i] = 1;
            }
            return 'A' + i;
        }
    }
    return 0;
}

static char find_doable_step(requirement_t* rs, int len,       //
                             int* deps, int* coms, int steps,  //
                             int instant_finish)               //
{
    memset(deps, 0, sizeof(int) * 26);
    update_deps(rs, len, deps, coms);
    return doable_step(deps, coms, steps, instant_finish);
}

static const char* steps_order_impl(void* arena, requirement_t* rs, int len)
{
    int deps[26] = {0};
    int coms[26] = {0};

    int steps = total_steps(rs, len);
    char* order = kt_linear_arena_array(arena, char, steps + 1);

    for (int i = 0; i < steps; i++) {
        order[i] = find_doable_step(rs, len, deps, coms, steps, 1);
    }
    order[steps] = 0;
    return order;
}

static int try_assign(char step, int work_time, int* com,  //
                      worker_t* woks, int workers)         //
{
    for (int i = 0; i < workers; i++) {
        if (woks[i].step == 0) {
            woks[i].step = step;
            woks[i].left = work_time + (step - 'A' + 1);
            com[step - 'A'] = 2;
            return 1;
        }
    }

    return 0;
}

static int update_works(worker_t* woks, int workers, int* com)
{
    int finished = 0;
    for (int i = 0; i < workers; i++) {
        if (woks[i].step == 0) continue;

        woks[i].left -= 1;
        if (woks[i].left == 0) {
            com[woks[i].step - 'A'] = 1;
            woks[i].step = 0;
            finished += 1;
        }
    }
    return finished;
}

static int multiworker_impl(void* arena,                 //
                            requirement_t* rs, int len,  //
                            int work_time, int workers)  //
{
    int deps[26] = {0};
    int coms[26] = {0};
    worker_t* woks = kt_linear_arena_array_zero(arena, worker_t, workers);

    int steps = total_steps(rs, len);
    int left_steps = steps;
    int tick = 0;

    while (left_steps > 0) {
        while (1) {
            char step = find_doable_step(rs, len, deps, coms, steps, 0);
            if (step) {
                int assigned = try_assign(step, work_time, coms, woks, workers);
                if (assigned) continue;
            }
            break;
        }
        left_steps -= update_works(woks, workers, coms);

        tick += 1;
    }

    return tick;
}

static context_t context_init(void* arena, const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);
    const char* line;
    int len = 0;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        len += 1;
    }

    requirement_t* rs = kt_linear_arena_array(arena, requirement_t, len);
    kt_scanner_reset(scanner);
    len = 0;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        requirement_from(line, rs + len);
        len += 1;
    }

    context_t ctx;
    ctx.rs = rs;
    ctx.len = len;
    return ctx;
}

const char* steps_order(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    context_t ctx = context_init(arena, input_file);
    const char* result = steps_order_impl(arena, ctx.rs, ctx.len);

    char* buf = kt_malloc(strlen(result) + 1);
    strcpy(buf, result);

    kt_linear_arena_deinit(arena);

    return buf;
}

int multiworker(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    context_t ctx = context_init(arena, input_file);

    int result = multiworker_impl(arena, ctx.rs, ctx.len, 60, 5);

    kt_linear_arena_deinit(arena);

    return result;
}

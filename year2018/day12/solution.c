#include "../lib/kt.h"

#define NOTE_SIZE 32
#define PLANT_EMPTY_SLOT 500
#define BUF_SIZE 256

typedef struct {
    char* plants;
    size_t cap;
    size_t head;
    size_t tail;
} plant_t;

typedef struct {
    plant_t plant;
    char* notes;
} context_t;

static plant_t plant_from(void* arena, const char* s)
{
    plant_t p;
    int len = strlen(s);
    size_t cap = 2 * PLANT_EMPTY_SLOT + len;
    p.plants = kt_linear_arena_array_zero(arena, char, cap);
    p.cap = cap;

    for (int i = 0; i < len; i++) {
        p.plants[PLANT_EMPTY_SLOT + i] = s[i] == '#' ? 1 : 0;
    }

    for (int i = 0; i < len; i++) {
        if (s[i] == '#') {
            p.head = PLANT_EMPTY_SLOT + i;
            break;
        }
    }

    for (int i = len - 1; i >= 0; i--) {
        if (s[i] == '#') {
            p.tail = PLANT_EMPTY_SLOT + i;
            break;
        }
    }

    return p;
}

static void plant_print(const plant_t* self, char* output)
{
    int i = self->head;
    for (; i <= (int)self->tail; i++) {
        char c = self->plants[i] ? '#' : '.';
        sprintf(output + i - self->head, "%c", c);
    }
    output[i - self->head] = 0;
}

static int plant_sum(const plant_t* self)
{
    int sum = 0;
    for (int i = self->head; i <= (int)self->tail; i++) {
        if (self->plants[i]) {
            sum += i - PLANT_EMPTY_SLOT;
        }
    }
    return sum;
}

static void plant_next_generation(plant_t* self, const char* notes)
{
    int start = self->head - 2;
    assert(start >= 0);
    int end = self->tail + 2;
    assert(end + 3 < (int)self->cap);

    int v = self->plants[self->head];

    for (int i = start; i <= end; i++) {
        self->plants[i] = notes[v];
        if (self->plants[i] && i < (int)self->head) {
            self->head = i;
        }
        if (self->plants[i] && i > (int)self->tail) {
            self->tail = i;
        }
        v = ((v & 0xF) << 1) | (self->plants[i + 3]);
    }

    while (self->plants[self->head] == 0) {
        self->head += 1;
    }
    while (self->plants[self->tail] == 0) {
        self->tail -= 1;
    }
}

static void note_parse(const char* s, char* notes)
{
    int v = 0;
    for (int i = 0; i < 5; i++) {
        int d = s[i] == '#' ? 1 : 0;
        v = (v << 1) | d;
    }
    notes[v] = s[9] == '#' ? 1 : 0;
}

static context_t context_init(void* arena, const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);

    const char* init_state = kt_scanner_next(scanner, '\n');
    kt_scanner_next(scanner, '\n');
    plant_t plant = plant_from(arena, init_state + 15);

    char* notes = kt_linear_arena_array_zero(arena, char, 32);
    const char* line;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        note_parse(line, notes);
    }

    kt_scanner_deinit(scanner);

    context_t ctx;
    ctx.plant = plant;
    ctx.notes = notes;
    return ctx;
}

static int sum_plants_impl(plant_t* plant, char* notes, long generations)
{
    for (long i = 0; i < generations; i++) {
        plant_next_generation(plant, notes);
    }
    return plant_sum(plant);
}

static long sum_plants2_impl(plant_t* plant, char* notes, long generations)
{
    char prev[BUF_SIZE] = {0};
    char curr[BUF_SIZE] = {0};

    long i = 0;
    for (; i < generations; i++) {
        plant_next_generation(plant, notes);
        plant_print(plant, curr);

        // find loop
        if (strcmp(prev, curr) == 0) break;
        strcpy(prev, curr);
    }

    long left = generations - 1 - i;
    long result = 0;
    for (size_t j = plant->head; j <= plant->tail; j++) {
        if (plant->plants[j]) {
            result += j + left - (long)PLANT_EMPTY_SLOT;
        }
    }

    return result;
}

int sum_plants(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    context_t ctx = context_init(arena, input_file);
    int result = sum_plants_impl(&ctx.plant, ctx.notes, 20);

    kt_linear_arena_deinit(arena);

    return result;
}

long sum_plants2(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    context_t ctx = context_init(arena, input_file);
    long result = sum_plants2_impl(&ctx.plant, ctx.notes, 50000000000);

    kt_linear_arena_deinit(arena);

    return result;
}

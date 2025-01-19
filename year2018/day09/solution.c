#include <stdio.h>

#include "../lib/kt.h"
#define OVERFLOW 100000000

typedef struct marble {
    struct marble* prev;
    struct marble* next;
    int val;
} marble_t;

static marble_t* marble_init(void* arena)
{
    marble_t* header = kt_linear_arena_create(arena, marble_t);
    header->prev = header;
    header->next = header;
    header->val = 0;
    return header;
}

static marble_t* marble_place(void* arena, marble_t* curr, int val)
{
    marble_t* next = curr->next;
    marble_t* node = kt_linear_arena_create(arena, marble_t);
    node->val = val;
    node->next = next->next;
    node->next->prev = node;
    node->prev = next;
    node->prev->next = node;
    return node;
}

static marble_t* marble_remove(marble_t* curr, int* val)
{
    for (int i = 0; i < 7; i++) {
        curr = curr->prev;
    }
    *val += curr->val;
    marble_t* prev = curr->prev;
    marble_t* next = curr->next;
    prev->next = next;
    next->prev = prev;
    return next;
}

static long highest_score_impl(void* arena, int players, int last)
{
    int* scores = kt_linear_arena_array_zero(arena, int, players);
    int* overflows = kt_linear_arena_array_zero(arena, int, players);
    marble_t* curr = marble_init(arena);
    for (int i = 1; i <= last; i++) {
        if (i % 23 == 0) {
            int player_idx = (i - 1) % players;
            scores[player_idx] += i;
            curr = marble_remove(curr, scores + player_idx);
            if (scores[player_idx] > OVERFLOW) {
                scores[player_idx] -= OVERFLOW;
                overflows[player_idx] += 1;
            }
        } else {
            curr = marble_place(arena, curr, i);
        }
    }

    long max = 0;
    for (int i = 0; i < players; i++) {
        long score = (long)scores[i] + (long)overflows[i] * OVERFLOW;
        if (score > max) {
            max = score;
        }
    }

    return max;
}

int highest_score(const char* input_file)
{
    UNUSED(input_file);

    void* arena = kt_linear_arena_init(8 * 1024 * 1024);
    int result = highest_score_impl(arena, 438, 71626);
    kt_linear_arena_deinit(arena);
    return result;
}

long highest_score2(const char* input_file)
{
    UNUSED(input_file);

    void* arena = kt_linear_arena_init(256 * 1024 * 1024);
    long result = highest_score_impl(arena, 438, 71626 * 100);
    kt_linear_arena_deinit(arena);
    return result;
}

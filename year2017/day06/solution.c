#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/// http://www.cse.yorku.ca/~oz/hash.html
/// djb2
static unsigned long hash(const char* str)
{
    unsigned long hash = 5381;
    char c;

    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
    }

    return hash;
}

typedef struct slot {
    const char* key;
    int val;
    int occupied;
} slot_t;

typedef struct hashmap {
    slot_t* slots;
    int size;
    int cap;
} hashmap_t;

static hashmap_t hashmap_init(int cap)
{
    slot_t* slots = calloc(cap, sizeof(slot_t));
    hashmap_t set = {.slots = slots, .size = 0, .cap = cap};
    return set;
}

static void hashmap_destory(hashmap_t* set)
{
    free(set->slots);
    set->slots = NULL;
    set->size = 0;
    set->cap = 0;
}

static int hashmap_find_slot(hashmap_t* set, const char* key)
{
    int i = hash(key) % set->cap;
    while (1) {
        slot_t slot = set->slots[i];
        if (!slot.occupied) break;

        if (strcmp(slot.key, key) == 0) {
            break;
        }

        i = (i + 1) % set->cap;
    }
    return i;
}

static int hashmap_has(hashmap_t* set, const char* key)
{
    int i = hashmap_find_slot(set, key);
    return set->slots[i].occupied;
}

static int hashmap_get(hashmap_t* set, const char* key)
{
    int i = hashmap_find_slot(set, key);
    return set->slots[i].val;
}

static void hashmap_put(hashmap_t* set, const char* key, int val)
{
    int i = hashmap_find_slot(set, key);
    if (set->slots[i].occupied == 0) {
        set->size += 1;
    }
    set->slots[i].key = key;
    set->slots[i].val = val;
    set->slots[i].occupied = 1;

    // almost full
    if (set->size * 2 > set->cap) {
        hashmap_t new_set = hashmap_init(set->cap * 2);
        for (int i = 0; i < set->cap; i++) {
            if (set->slots[i].occupied) {
                hashmap_put(&new_set, set->slots[i].key, set->slots[i].val);
            }
        }
        hashmap_destory(set);
        set->slots = new_set.slots;
        set->size = new_set.size;
        set->cap = new_set.cap;
    }
}

static const char* array_to_str(int* block, int len)
{
    char* str = malloc(3 * len);
    char* p = str;
    for (int i = 0; i < len; i++) {
        p += sprintf(p, "%d,", block[i]);
    }
    *--p = '\0';
    return str;
}

static void do_redistribution(int* block, int len)
{
    int max_i = 0;
    for (int i = 1; i < len; i++) {
        if (block[i] > block[max_i]) {
            max_i = i;
        }
    }

    int v = block[max_i];
    block[max_i] = 0;
    int i = max_i;
    while (v > 0) {
        i = (i + 1) % len;
        block[i] += 1;
        v -= 1;
    }
}

typedef struct cycle_info {
    int cycle;
    int loop;
} cycle_info_t;

cycle_info_t redistribution_cycles(int* block, int len)
{
    hashmap_t set = hashmap_init(64);

    const char* key = array_to_str(block, len);
    hashmap_put(&set, key, 0);

    int cycle = 0;
    int loop = 0;
    while (1) {
        do_redistribution(block, len);
        cycle += 1;
        const char* new_key = array_to_str(block, len);
        if (hashmap_has(&set, new_key)) {
            loop = cycle - hashmap_get(&set, new_key);
            break;
        }
        hashmap_put(&set, new_key, cycle);
    }

    for (int i = 0; i < set.cap; i++) {
        slot_t slot = set.slots[i];
        if (slot.occupied) {
            free((void*)slot.key);
        }
    }
    hashmap_destory(&set);

    return (cycle_info_t){.cycle = cycle, .loop = loop};
}

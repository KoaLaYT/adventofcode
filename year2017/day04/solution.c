#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/// http://www.cse.yorku.ca/~oz/hash.html
/// djb2
static unsigned long hash(const char* str, int len)
{
    unsigned long hash = 5381;

    for (int i = 0; i < len; i++) {
        hash = ((hash << 5) + hash) + str[i]; /* hash * 33 + c */
    }

    return hash;
}

static void bubble_sort(char* str, int len)
{
    for (int i = 0; i < len; i++) {
        int min = i;
        for (int j = i + 1; j < len; j++) {
            if (str[j] < str[min]) {
                min = j;
            }
        }
        char temp = str[i];
        str[i] = str[min];
        str[min] = temp;
    }
}

typedef struct slot {
    char* key;
    int key_len;
    int occupied;
} slot_t;

typedef struct hashset {
    slot_t* slots;
    int size;
} hashset_t;

static hashset_t hashset_init(int size)
{
    slot_t* slots = calloc(size, sizeof(slot_t));
    hashset_t set = {.slots = slots, .size = size};
    return set;
}

static void hashset_destory(hashset_t* set)
{
    free(set->slots);
    set->slots = NULL;
    set->size = 0;
}

static void hashset_print(hashset_t* set)
{
    for (int i = 0; i < set->size; i++) {
        printf("slot[%d]: ", i);
        slot_t slot = set->slots[i];
        if (slot.occupied) {
            for (int j = 0; j < slot.key_len; j++) {
                printf("%c", slot.key[j]);
            }
        } else {
            printf("<empty>");
        }
        printf("\n");
    }
}

static int hashset_find_slot(hashset_t* set, char* key, int key_len)
{
    int i = hash(key, key_len) % set->size;
    while (1) {
        slot_t slot = set->slots[i];
        if (!slot.occupied) break;

        if (slot.key_len == key_len && strncmp(slot.key, key, key_len) == 0) {
            break;
        }

        i = (i + 1) % set->size;
    }
    return i;
}

static int hashset_has(hashset_t* set, char* key, int key_len)
{
    int i = hashset_find_slot(set, key, key_len);
    return set->slots[i].occupied;
}

static void hashset_put(hashset_t* set, char* key, int key_len)
{
    int i = hashset_find_slot(set, key, key_len);
    set->slots[i].key = key;
    set->slots[i].key_len = key_len;
    set->slots[i].occupied = 1;
}

int is_valid(char* passphrase, int len)
{
    int i = 0;
    int j = 0;
    hashset_t set = hashset_init(32);

    while (j < len) {
        while (j < len && passphrase[j] != ' ') j++;
        if (hashset_has(&set, passphrase + i, j - i)) {
            hashset_destory(&set);
            return 0;
        }
        hashset_put(&set, passphrase + i, j - i);
        i = j + 1;
        j = i;
    }

    hashset_destory(&set);
    return 1;
}

int is_valid_v2(char* passphrase, int len)
{
    int i = 0;
    int j = 0;
    hashset_t set = hashset_init(64);

    while (j < len) {
        while (j < len && passphrase[j] != ' ') j++;
        bubble_sort(passphrase + i, j - i);
        if (hashset_has(&set, passphrase + i, j - i)) {
            hashset_destory(&set);
            return 0;
        }
        hashset_put(&set, passphrase + i, j - i);
        i = j + 1;
        j = i;
    }

    hashset_destory(&set);
    return 1;
}

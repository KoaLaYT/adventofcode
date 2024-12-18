#include <stdlib.h>

typedef struct node {
    int v;
    struct node* n;
} node_t;

static node_t* node_new(int v)
{
    node_t* n = malloc(sizeof(node_t));
    n->v = v;
    n->n = 0;
    return n;
}

static void node_free(node_t* header)
{
    node_t* cur = header;
    while (cur != 0) {
        node_t* next = cur->n;
        free(cur);
        cur = next;
    }
}

int value_after(int step, int insertions)
{
    node_t* header = node_new(0);

    node_t* cur = header;
    for (int i = 1; i <= insertions; i++) {
        for (int j = 0; j < step; j++) {
            if (cur->n != 0) {
                cur = cur->n;
            } else {
                cur = header;
            }
        }
        node_t* new_node = node_new(i);
        node_t* next_node = cur->n;
        cur->n = new_node;
        new_node->n = next_node;
        cur = new_node;
    }

    int v = cur->n->v;
    node_free(header);
    return v;
}

int value_after_zero(int step, int insertions)
{
    int v = 0;
    int p = 0;
    for (int i = 1; i <= insertions; i++) {
        p = (p + step) % i + 1;
        if (p == 1) v = i;
    }

    return v;
}

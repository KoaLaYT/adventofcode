#include <stdlib.h>

#define OFFSET 10
#define ABS(x) ((x < 0) ? (-x) : (x))
#define ID(x, y) ((OFFSET + y) * 2 * OFFSET + (OFFSET + x))

typedef enum Dir { RIGHT, UP, LEFT, DOWN, MAX_DIRS } Dir_t;

int distance(int square)
{
    Dir_t dir = RIGHT;
    int hor = 0;
    int ver = 0;
    int x = 0;
    int y = 0;

    int i = 1;
    while (i < square) {
        if (dir == RIGHT || dir == LEFT) {
            hor += 1;
        } else {
            ver += 1;
        }

        int move;
        int dx;
        int dy;

        switch (dir) {
            case UP:
                move = ver;
                dx = 0;
                dy = 1;
                break;
            case RIGHT:
                move = hor;
                dx = 1;
                dy = 0;
                break;
            case DOWN:
                move = ver;
                dx = 0;
                dy = -1;
                break;
            case LEFT:
                move = hor;
                dx = -1;
                dy = 0;
                break;
            default:
                return -1;
                break;
        }

        for (int j = 0; j < move; j++) {
            x += dx;
            y += dy;
            i += 1;
            if (i == square) break;
        }

        dir = (dir + 1) % MAX_DIRS;
    }

    return ABS(x) + ABS(y);
}

int value(int target)
{
    Dir_t dir = RIGHT;
    int hor = 0;
    int ver = 0;
    int x = 0;
    int y = 0;
    int* map = malloc(4 * OFFSET * OFFSET * sizeof(int));
    for (int i = 0; i < 4 * OFFSET * OFFSET; i++) {
        map[i] = 0;
    }
    map[ID(0, 0)] = 1;

    while (1) {
        if (dir == RIGHT || dir == LEFT) {
            hor += 1;
        } else {
            ver += 1;
        }

        int move;
        int dx;
        int dy;

        switch (dir) {
            case UP:
                move = ver;
                dx = 0;
                dy = 1;
                break;
            case RIGHT:
                move = hor;
                dx = 1;
                dy = 0;
                break;
            case DOWN:
                move = ver;
                dx = 0;
                dy = -1;
                break;
            case LEFT:
                move = hor;
                dx = -1;
                dy = 0;
                break;
            default:
                return -1;
                break;
        }

        for (int j = 0; j < move; j++) {
            x += dx;
            y += dy;

            int v = 0;
            for (int xx = -1; xx <= 1; xx++) {
                for (int yy = -1; yy <= 1; yy++) {
                    v += map[ID(x + xx, y + yy)];
                }
            }
            if (v > target) return v;
            map[ID(x, y)] = v;
        }

        dir = (dir + 1) % MAX_DIRS;
    }
}

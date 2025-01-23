#include "../lib/kt.h"

typedef enum { dir_up, dir_right, dir_down, dir_left } dir_t;

typedef struct {
    int x, y;
    dir_t dir;
    int turn;
} cart_t;

typedef struct {
    char* arr;
    int width, height;
} track_t;

typedef struct {
    track_t track;
    cart_t* carts;
    int cart_len;
} context_t;

static track_t track_init(void* arena, int width, int height)
{
    track_t t;
    t.arr = kt_linear_arena_array_zero(arena, char, width* height);
    memset(t.arr, ' ', width * height);
    t.width = width;
    t.height = height;
    return t;
}

static void cart_insert(cart_t* carts, int* cart_len, int x, int y, int dir)
{
    carts[*cart_len].x = x;
    carts[*cart_len].y = y;
    carts[*cart_len].dir = dir;
    carts[*cart_len].turn = 0;
    *cart_len += 1;
}

static void parse_line(const char* s,                 //
                       track_t* t, int y,             //
                       cart_t* carts, int* cart_len)  //
{
    for (int i = 0; s[i] != 0; i += 1) {
        if (s[i] == ' ') continue;

        char c = s[i];
        if (s[i] == '^') {
            cart_insert(carts, cart_len, i, y, dir_up);
            c = '|';
        } else if (s[i] == '>') {
            cart_insert(carts, cart_len, i, y, dir_right);
            c = '-';
        } else if (s[i] == 'v') {
            cart_insert(carts, cart_len, i, y, dir_down);
            c = '|';
        } else if (s[i] == '<') {
            cart_insert(carts, cart_len, i, y, dir_left);
            c = '-';
        }
        t->arr[t->width * y + i] = c;
    }
}

static void cart_sort(cart_t* carts, int len)
{
    for (int i = 0; i < len; i++) {
        int p = i;
        for (int j = i + 1; j < len; j++) {
            if (carts[j].y < carts[p].y) {
                p = j;
            } else if (carts[j].y == carts[p].y && carts[j].x < carts[p].x) {
                p = j;
            }
        }
        if (p != i) {
            cart_t temp = carts[p];
            carts[p] = carts[i];
            carts[i] = temp;
        }
    }
}

static context_t context_init(void* arena, const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);

    const char* line;
    int width = 0;
    int height = 0;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        int len = strlen(line);
        if (len > width) {
            width = len;
        }
        height += 1;
    }
    kt_scanner_reset(scanner);

    track_t track = track_init(arena, width, height);
    cart_t* carts = kt_linear_arena_array_zero(arena, cart_t, 64);
    int cart_len = 0;
    int row = 0;
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        parse_line(line, &track, row, carts, &cart_len);
        assert(cart_len < 64);
        row += 1;
    }
    kt_scanner_deinit(scanner);

    context_t ctx;
    ctx.track = track;
    ctx.carts = carts;
    ctx.cart_len = cart_len;
    return ctx;
}

static void cart_turn_left(cart_t* cart)
{
    switch (cart->dir) {
        case dir_up:
            cart->dir = dir_left;
            break;
        case dir_right:
            cart->dir = dir_up;
            break;
        case dir_down:
            cart->dir = dir_right;
            break;
        case dir_left:
            cart->dir = dir_down;
            break;
    }
}

static void cart_turn_right(cart_t* cart)
{
    switch (cart->dir) {
        case dir_up:
            cart->dir = dir_right;
            break;
        case dir_right:
            cart->dir = dir_down;
            break;
        case dir_down:
            cart->dir = dir_left;
            break;
        case dir_left:
            cart->dir = dir_up;
            break;
    }
}

static void cart_turn_at_cross(cart_t* cart)
{
    if (cart->turn == 0) {
        cart_turn_left(cart);
    } else if (cart->turn == 2) {
        cart_turn_right(cart);
    }
    cart->turn = (cart->turn + 1) % 3;
}

static void cart_turn_at_corner(cart_t* cart, char c)
{
    if (c == '/') {
        switch (cart->dir) {
            case dir_up:
                cart_turn_right(cart);
                break;
            case dir_left:
                cart_turn_left(cart);
                break;
            case dir_right:
                cart_turn_left(cart);
                break;
            case dir_down:
                cart_turn_right(cart);
                break;
        }
    }
    if (c == '\\') {
        switch (cart->dir) {
            case dir_up:
                cart_turn_left(cart);
                break;
            case dir_left:
                cart_turn_right(cart);
                break;
            case dir_right:
                cart_turn_right(cart);
                break;
            case dir_down:
                cart_turn_left(cart);
                break;
        }
    }
}

static void cart_move(cart_t* cart, const track_t* track)
{
    int dx = 0, dy = 0;
    switch (cart->dir) {
        case dir_up:
            dy = -1;
            break;
        case dir_right:
            dx = 1;
            break;
        case dir_down:
            dy = 1;
            break;
        case dir_left:
            dx = -1;
            break;
    }

    cart->x += dx;
    cart->y += dy;

    char c = track->arr[track->width * cart->y + cart->x];
    assert(c != ' ');

    if (c == '-' || c == '|') return;

    if (c == '+') {
        cart_turn_at_cross(cart);
    } else {
        cart_turn_at_corner(cart, c);
    }
}

static int cart_crash(cart_t* carts, int len, int i)
{
    for (int j = 0; j < len; j++) {
        if (j == i) continue;
        cart_t c1 = carts[i];
        cart_t c2 = carts[j];
        if (c1.x == c2.x && c1.y == c2.y) {
            return j;
        }
    }
    return -1;
}

static const char* cart_location(cart_t cart)
{
    char* buf = kt_malloc(64);
    int n = sprintf(buf, "%d,%d", cart.x, cart.y);
    buf[n] = 0;
    return buf;
}

static const char* first_crash_impl(const track_t* track,    //
                                    cart_t* carts, int len)  //
{
    for (;;) {
        cart_sort(carts, len);

        for (int i = 0; i < len; i++) {
            cart_move(&carts[i], track);
            if (cart_crash(carts, len, i) >= 0) {
                return cart_location(carts[i]);
            }
        }
    }
}

static const char* last_cart_impl(const track_t* track,    //
                                  cart_t* carts, int len)  //
{
    char buf[64] = {0};
    assert(len < 64);

    while (len > 1) {
        cart_sort(carts, len);
        memset(buf, 0, 64);
        int crashed = 0;

        for (int i = 0; i < len; i += 1) {
            if (buf[i] == 1) continue;
            cart_move(&carts[i], track);
            int j = cart_crash(carts, len, i);
            if (j >= 0) {
                buf[i] = 1;
                buf[j] = 1;
                crashed += 1;
            }
        }

        if (crashed) {
            int left_len = 0;
            for (int i = 0; i < len; i++) {
                if (buf[i] == 1) {
                    continue;
                }
                carts[left_len++] = carts[i];
            }
            len = left_len;
        }
    }
    assert(len == 1);
    return cart_location(carts[0]);
}

const char* first_crash(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    context_t ctx = context_init(arena, input_file);
    const char* result = first_crash_impl(&ctx.track, ctx.carts, ctx.cart_len);
    kt_linear_arena_deinit(arena);
    return result;
}

const char* last_cart(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    context_t ctx = context_init(arena, input_file);
    const char* result = last_cart_impl(&ctx.track, ctx.carts, ctx.cart_len);
    kt_linear_arena_deinit(arena);
    return result;
}

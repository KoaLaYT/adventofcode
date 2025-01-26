#include "../lib/kt.h"

#define REACHABLE_CAP 128
#define QUEUE_CAP 128
#define POWER 3
#define HP 200

#define NONE_MOVEABLE -2
#define EMPTY -1

typedef enum { dir_up, dir_right, dir_down, dir_left } dir_t;

typedef struct {
    i32 x, y;
} pos_t;

typedef struct {
    i32 x, y;
    i32 power;
    i32 hp;
    b8 actioned;
} unit_t;

typedef struct {
    i32 head, tail, len;
    pos_t arr[QUEUE_CAP];
} queue_t;

typedef struct {
    unit_t* golbins;
    i32 golbin_left;

    unit_t* elfs;
    i32 elf_left;

    char* map;
    i32 width, height;

    i32* buf;
    queue_t* q;
} game_t;

static void game_print(game_t* game, i32 round);
#define NDEBUG
#ifdef NDEBUG
#define DEBUG(format, ...)
#define DEBUG_GAME(game, round)
#else
#define DEBUG(format, ...) printf(format, __VA_ARGS__)
#define DEBUG_GAME(game, round) game_print(game, round)
#endif

static void game_queue_reset(game_t* game)
{
    game->q->head = 0;
    game->q->tail = 0;
    game->q->len = 0;
}

static i32 game_queue_len(game_t* game) { return game->q->len; }

static void game_queue_push(game_t* game, pos_t p)
{
    if (game->q->len == QUEUE_CAP) {
        perror("queue out of boundary");
        exit(1);
    }
    game->q->arr[game->q->tail] = p;
    game->q->tail = (game->q->tail + 1) % QUEUE_CAP;
    game->q->len += 1;
}

static pos_t game_queue_pop(game_t* game)
{
    if (game->q->len == 0) {
        perror("queue is empty");
        exit(1);
    }
    pos_t p = game->q->arr[game->q->head];
    game->q->head = (game->q->head + 1) % QUEUE_CAP;
    game->q->len -= 1;
    return p;
}

static void unit_init(unit_t* u, i32 x, i32 y)
{
    u->x = x;
    u->y = y;
    u->power = POWER;
    u->hp = HP;
    u->actioned = FALSE;
}

static pos_t unit_pos(const unit_t* u)
{
    pos_t p;
    p.x = u->x;
    p.y = u->y;
    return p;
}

static pos_t unit_pos_at(const unit_t* u, dir_t dir)
{
    i8 dx = 0;
    i8 dy = 0;
    switch (dir) {
        case dir_up:
            dy = -1;
            break;
        case dir_left:
            dx = -1;
            break;
        case dir_right:
            dx = 1;
            break;
        case dir_down:
            dy = 1;
            break;
    }

    pos_t p;
    p.x = u->x + dx;
    p.y = u->y + dy;
    return p;
}

static game_t game_init(void* arena, const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);

    const char* line;
    i32 width = 0, height = 0;
    i32 golbin_left = 0, elf_left = 0;

    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        i32 i = 0;
        char c = 0;
        while ((c = line[i]) != 0) {
            if (c == 'G') golbin_left += 1;
            if (c == 'E') elf_left += 1;
            i += 1;
        }
        width = i;
        height += 1;
    }
    kt_scanner_reset(scanner);

    unit_t* golbins = kt_linear_arena_array_zero(arena, unit_t, golbin_left);
    unit_t* elfs = kt_linear_arena_array_zero(arena, unit_t, elf_left);
    char* map = kt_linear_arena_array_zero(arena, char, width* height);
    i32* buf = kt_linear_arena_array_zero(arena, i32, width * height);
    i32 y = 0, gi = 0, ei = 0;

    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        i32 x = 0;
        char c = 0;
        while ((c = line[x]) != 0) {
            map[y * width + x] = c;
            if (c == 'G') {
                unit_init(golbins + gi, x, y);
                gi += 1;
            }
            if (c == 'E') {
                unit_init(elfs + ei, x, y);
                ei += 1;
            }
            x += 1;
        }
        assert(x == width);
        y += 1;
    }
    kt_scanner_deinit(scanner);

    assert(gi == golbin_left);
    assert(ei == elf_left);
    assert(y == height);

    game_t game;
    game.golbins = golbins;
    game.golbin_left = golbin_left;
    game.elfs = elfs;
    game.elf_left = elf_left;
    game.map = map;
    game.width = width;
    game.height = height;
    game.buf = buf;
    game.q = kt_linear_arena_create_zero(arena, queue_t);
    return game;
}

static game_t game_copy(void* arena, game_t* game)
{
    game_t copy;
    copy.golbins = kt_linear_arena_array_zero(arena, unit_t, game->golbin_left);
    copy.golbin_left = game->golbin_left;
    copy.elfs = kt_linear_arena_array_zero(arena, unit_t, game->elf_left);
    copy.elf_left = game->elf_left;
    copy.map =
        kt_linear_arena_array_zero(arena, char, game->width * game->height);
    copy.width = game->width;
    copy.height = game->height;
    copy.buf =
        kt_linear_arena_array_zero(arena, i32, game->width * game->height);
    copy.q = kt_linear_arena_create_zero(arena, queue_t);
    return copy;
}

static void game_reset(game_t* game, game_t* init_game, i32 elf_power)
{
    for (i32 i = 0; i < init_game->golbin_left; i++) {
        game->golbins[i] = init_game->golbins[i];
    }
    game->golbin_left = init_game->golbin_left;

    for (i32 i = 0; i < init_game->elf_left; i++) {
        game->elfs[i] = init_game->elfs[i];
        game->elfs[i].power = elf_power;
    }
    game->elf_left = init_game->elf_left;

    for (i32 y = 0; y < game->height; y++) {
        for (i32 x = 0; x < game->width; x++) {
            i32 idx = y * game->width + x;
            game->map[idx] = init_game->map[idx];
        }
    }
}

static unit_t* game_find_unit_at(game_t* game, i32 x, i32 y)
{
    for (i32 i = 0; i < game->golbin_left; i++) {
        unit_t unit = game->golbins[i];
        if (unit.x == x && unit.y == y) {
            return game->golbins + i;
        }
    }
    for (i32 i = 0; i < game->elf_left; i++) {
        unit_t unit = game->elfs[i];
        if (unit.x == x && unit.y == y) {
            return game->elfs + i;
        }
    }
    ASSERT_MSG(0, "cannot find unit at %d,%d", x, y);
}

static char game_map_at(game_t* game, i32 x, i32 y)
{
    i32 i = y * game->width + x;
    if (i >= 0 && i < game->width * game->height) {
        return game->map[i];
    }
    return 0;
}

static void game_buf_reset(game_t* game)
{
    for (i32 y = 0; y < game->height; y++) {
        for (i32 x = 0; x < game->width; x++) {
            i32 i = y * game->width + x;
            game->buf[i] = (game->map[i] == '.') ? EMPTY : NONE_MOVEABLE;
        }
    }
}

static i32 game_buf_at(game_t* game, i32 x, i32 y)
{
    i32 i = y * game->width + x;
    if (i >= 0 && i < game->width * game->height) {
        return game->buf[i];
    }
    return NONE_MOVEABLE;
}

static i32 game_buf_step_at(game_t* game, i32 x, i32 y,  //
                            i32 shortest, i32* mx, i32* my)
{
    i32 v = game_buf_at(game, x, y);
    if (v == NONE_MOVEABLE || v == EMPTY) {
        return shortest;
    }

    if (shortest < 0 || v < shortest) {
        *mx = x;
        *my = y;
        return v;
    }
    return shortest;
}

static unit_t* game_next_unit(game_t* game, i32 nx, i32 ny)
{
    i32 y = ny;
    i32 x = nx + 1;

    for (; y < game->height; y++) {
        for (; x < game->width; x++) {
            char c = game_map_at(game, x, y);
            if (c == 'G' || c == 'E') {
                unit_t* u = game_find_unit_at(game, x, y);
                if (!u->actioned) return u;
            }
        }
        x = 0;
    }
    return 0;
}

static void game_remove(game_t* game, unit_t* unit)
{
    game->map[unit->y * game->width + unit->x] = '.';

    for (i32 i = 0; i < game->golbin_left; i++) {
        if (game->golbins + i == unit) {
            game->golbins[i] = game->golbins[game->golbin_left - 1];
            game->golbin_left -= 1;
            return;
        }
    }
    for (i32 i = 0; i < game->elf_left; i++) {
        if (game->elfs + i == unit) {
            game->elfs[i] = game->elfs[game->elf_left - 1];
            game->elf_left -= 1;
            return;
        }
    }
    ASSERT_MSG(0, "cannot remove unit at (%d,%d)", unit->x, unit->y);
}

static unit_t* game_find_enemy_at(game_t* game,               //
                                  char target, i32 x, i32 y,  //
                                  unit_t* found)
{
    if (game_map_at(game, x, y) == target) {
        unit_t* u = game_find_unit_at(game, x, y);
        if (!found || (u->hp < found->hp)) {
            return u;
        }
    }
    return found;
}

static b8 game_try_attack(game_t* game,               //
                          unit_t* unit, char target,  //
                          b8* has_elf_dead)           //
{
    unit_t* enemy = 0;
    enemy = game_find_enemy_at(game, target, unit->x, unit->y - 1, enemy);
    enemy = game_find_enemy_at(game, target, unit->x - 1, unit->y, enemy);
    enemy = game_find_enemy_at(game, target, unit->x + 1, unit->y, enemy);
    enemy = game_find_enemy_at(game, target, unit->x, unit->y + 1, enemy);

    if (!enemy) return FALSE;

    DEBUG("attack %c(%d,%d)\n", target, enemy->x, enemy->y);
    enemy->hp -= unit->power;
    if (enemy->hp <= 0) {
        game_remove(game, enemy);
        if (target == 'E' && has_elf_dead) *has_elf_dead = TRUE;
    }
    return TRUE;
}

static i32 game_find_path_at(game_t* game, pos_t from, pos_t to,  //
                             i32 shortest, i32* mx, i32* my)
{
    char c = game_map_at(game, from.x, from.y);
    if (c != '.') return shortest;

    game_buf_reset(game);
    game_queue_reset(game);

    game->buf[from.y * game->width + from.x] = 0;
    game_queue_push(game, from);
    i32 step = 0;

    while (game_queue_len(game) > 0) {
        step += 1;
        if (shortest >= 0 && step >= shortest) break;
        i32 size = game_queue_len(game);
        for (i32 i = 0; i < size; i++) {
            pos_t p = game_queue_pop(game);

            pos_t ns[4];
            i32 len = 0;
            // up
            if (game_buf_at(game, p.x, p.y - 1) == EMPTY) {
                ns[len].x = p.x;
                ns[len].y = p.y - 1;
                len += 1;
            }
            // left
            if (game_buf_at(game, p.x - 1, p.y) == EMPTY) {
                ns[len].x = p.x - 1;
                ns[len].y = p.y;
                len += 1;
            }
            // right
            if (game_buf_at(game, p.x + 1, p.y) == EMPTY) {
                ns[len].x = p.x + 1;
                ns[len].y = p.y;
                len += 1;
            }
            // down
            if (game_buf_at(game, p.x, p.y + 1) == EMPTY) {
                ns[len].x = p.x;
                ns[len].y = p.y + 1;
                len += 1;
            }
            for (i32 j = 0; j < len; j++) {
                pos_t n = ns[j];
                game->buf[n.y * game->width + n.x] = step;
                game_queue_push(game, n);
            }
        }
    }

    shortest = game_buf_step_at(game, to.x, to.y - 1, shortest, mx, my);
    shortest = game_buf_step_at(game, to.x - 1, to.y, shortest, mx, my);
    shortest = game_buf_step_at(game, to.x + 1, to.y, shortest, mx, my);
    shortest = game_buf_step_at(game, to.x, to.y + 1, shortest, mx, my);
    return shortest;
}

static void game_find_reachable_in_order(game_t* game,            //
                                         unit_t* units, i32 len,  //
                                         pos_t* ps, i32* p_len)   //
{
    dir_t dirs[] = {dir_up, dir_left, dir_right, dir_down};
    for (i32 i = 0; i < len; i++) {
        for (i32 j = 0; j < 4; j++) {
            pos_t p = unit_pos_at(units + i, dirs[j]);
            if (game_map_at(game, p.x, p.y) == '.') {
                ps[*p_len] = p;
                *p_len += 1;
                ASSERT_MSG(*p_len < REACHABLE_CAP,
                           "reachable outof boundary %d", len);
            }
        }
    }

    for (i32 i = 0; i < *p_len; i++) {
        i32 p = i;
        for (i32 j = i + 1; j < *p_len; j++) {
            pos_t a = ps[p];
            pos_t b = ps[j];
            if ((b.y * game->width + b.x) < (a.y * game->width + a.x)) {
                p = j;
            }
        }
        if (p != i) {
            pos_t temp = ps[i];
            ps[i] = ps[p];
            ps[p] = temp;
        }
    }
}

static void game_try_move(game_t* game, unit_t* unit, char type)
{
    unit_t* units = type == 'E' ? game->golbins : game->elfs;
    i32 len = type == 'E' ? game->golbin_left : game->elf_left;

    pos_t ps[128];
    i32 p_len = 0;
    game_find_reachable_in_order(game, units, len, ps, &p_len);

    pos_t target = unit_pos(unit);
    i32 mx, my;
    i32 shortest = -1;
    for (i32 i = 0; i < p_len; i++) {
        shortest = game_find_path_at(game, ps[i], target, shortest, &mx, &my);
    }

    if (shortest >= 0) {
        ASSERT_MSG(game_map_at(game, mx, my) == '.',  //
                   "move to bad place (%d,%d)", mx, my);
        game->map[unit->y * game->width + unit->x] = '.';
        game->map[my * game->width + mx] = type;
        unit->x = mx;
        unit->y = my;
        DEBUG("move (%d,%d)\n", mx, my);
    } else {
        DEBUG("%s\n", "do nothing");
    }
}

static b8 game_action(game_t* game, unit_t* unit, b8* has_elf_dead)
{
    char c = game->map[unit->y * game->width + unit->x];
    ASSERT_MSG(c == 'G' || c == 'E', "not a unit at %d,%d", unit->x, unit->y);

    char t = c == 'G' ? 'E' : 'G';
    DEBUG("%c(%d,%d) ", c, unit->x, unit->y);
    b8 attacked = game_try_attack(game, unit, t, has_elf_dead);
    if (!attacked) {
        game_try_move(game, unit, c);
        game_try_attack(game, unit, t, has_elf_dead);
    }
    unit->actioned = TRUE;

    return game->golbin_left == 0 || game->elf_left == 0;
}

static void game_units_reset(game_t* game)
{
    for (i32 i = 0; i < game->golbin_left; i++) {
        game->golbins[i].actioned = FALSE;
    }
    for (i32 i = 0; i < game->elf_left; i++) {
        game->elfs[i].actioned = FALSE;
    }
}

static void game_print(game_t* game, i32 round)
{
    printf("After %d round:\n", round);
    for (i32 y = 0; y < game->height; y++) {
        for (i32 x = 0; x < game->width; x++) {
            printf("%c", game_map_at(game, x, y));
        }
        printf("\n");
    }
    for (i32 i = 0; i < game->golbin_left; i++) {
        unit_t u = game->golbins[i];
        printf("G(%d,%d):%d\n", u.x, u.y, u.hp);
    }
    for (i32 i = 0; i < game->elf_left; i++) {
        unit_t u = game->elfs[i];
        printf("E(%d,%d):%d\n", u.x, u.y, u.hp);
    }
    printf("\n");
}

static i32 game_left_hps(game_t* game)
{
    i32 hp = 0;
    for (i32 i = 0; i < game->golbin_left; i++) {
        hp += game->golbins[i].hp;
    }
    for (i32 i = 0; i < game->elf_left; i++) {
        hp += game->elfs[i].hp;
    }
    return hp;
}

static b8 game_is_full_round(game_t* game)
{
    for (i32 i = 0; i < game->golbin_left; i++) {
        if (!game->golbins[i].actioned) return FALSE;
    }
    for (i32 i = 0; i < game->elf_left; i++) {
        if (!game->elfs[i].actioned) return FALSE;
    }
    return TRUE;
}

static i32 game_start(game_t* game, b8* has_elf_dead)
{
    i32 round = 0;

    for (;;) {
        round += 1;
        unit_t* unit = 0;
        b8 is_end = 0;
        i32 nx = 0, ny = 0;

        game_units_reset(game);
        while ((unit = game_next_unit(game, nx, ny)) != 0) {
            nx = unit->x;
            ny = unit->y;

            is_end = game_action(game, unit, has_elf_dead);
            if (has_elf_dead) is_end |= *has_elf_dead;
            if (is_end) break;
        }
        DEBUG_GAME(game, round);
        if (is_end) break;
    }

    if (!game_is_full_round(game)) round -= 1;
    i32 hp = game_left_hps(game);
    return round * hp;
}

static i32 game_start2(void* arena, game_t* init_game)
{
    game_t game = game_copy(arena, init_game);
    i32 elf_power = 4;
    i32 result = 0;
    for (;;) {
        game_reset(&game, init_game, elf_power);
        b8 has_elf_dead = FALSE;
        result = game_start(&game, &has_elf_dead);
        DEBUG("elf power %d, has elf dead %d\n", elf_power, has_elf_dead);
        if (!has_elf_dead) break;
        elf_power += 1;
    }
    return result;
}

i32 outcome(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    game_t game = game_init(arena, input_file);
    i32 result = game_start(&game, 0);

    kt_linear_arena_deinit(arena);

    return result;
}

i32 outcome2(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);

    game_t init_game = game_init(arena, input_file);
    i32 result = game_start2(arena, &init_game);

    kt_linear_arena_deinit(arena);

    return result;
}

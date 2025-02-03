#include "../lib/kt.h"
#include "../lib/re.h"

#define POOL_SIZE 64
#define ARRAY_SIZE 4

#define MIN(a, b) ((a) < (b) ? (a) : (b))

#define NDEBUG
#ifdef NDEBUG
#define DEBUG(...)
#else
#define DEBUG(...) printf(__VA_ARGS__);
#endif

typedef struct {
    i32 len;
    i32 arr[ARRAY_SIZE];
} array_t;

typedef struct group group_t;
struct group {
    i32 id;
    i32 units;
    i32 hp;
    i32 damage;
    i32 damage_type;
    array_t weak_types;
    array_t immune_types;
    i32 initiative;
    group_t* attack;
};

typedef struct {
    char* begin;
    char* end;
    char* vals[POOL_SIZE];
} type_pool_t;

typedef struct {
    group_t** immunes;
    group_t** immunes_selected;
    i32 immunes_len;

    group_t** infections;
    group_t** infections_selected;
    i32 infections_len;
} fight_t;

static void array_push(array_t* a, i32 v)
{
    ASSERT_MSG(a->len < ARRAY_SIZE, "array overflow %d", a->len);
    a->arr[a->len] = v;
    a->len += 1;
}

static type_pool_t type_pool_init(void* arena, i32 cap)
{
    type_pool_t p = {0};
    p.begin = kt_linear_arena_array_zero(arena, char, cap);
    p.end = p.begin + cap;
    return p;
}

u64 djb2_hash(const char* str, i32 len)
{
    u64 hash = 5381;
    for (i32 i = 0; i < len; i += 1) {
        const char c = str[i];
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
    }
    return hash;
}

static b8 str_equal(const char* s1, const char* s2, i32 len)
{
    i32 i = 0;
    for (; i < len; i++) {
        if (s1[i] != s2[i]) return FALSE;
    }
    return s1[i] == 0;
}

static void str_copy(char* s1, const char* s2, i32 len)
{
    for (i32 i = 0; i < len; i++) {
        s1[i] = s2[i];
    }
}

static i32 type_pool_get(type_pool_t* pool, const char* type, i32 len)
{
    u64 hash = djb2_hash(type, len);
    i32 loop = 0;
    for (u64 i = hash;;) {
        i = (i + 1) % POOL_SIZE;
        char* val = pool->vals[i];
        if (!val) {
            ASSERT_MSG(pool->begin + len + 1 < pool->end,  //
                       "str pool overflow %d", len);
            str_copy(pool->begin, type, len);
            pool->vals[i] = pool->begin;
            pool->begin += len + 1;
            return i;
        } else if (str_equal(val, type, len)) {
            return i;
        }
        loop += 1;
        ASSERT_MSG(loop++ < POOL_SIZE, "pool overflow %d", POOL_SIZE);
    }
}

static group_t group_from(const char* s, type_pool_t* pool, i32 id)
{
    group_t g = {0};
    g.id = id;
    i32 len;

    s += re_match("\\d+", s, &len);
    g.units = kt_atoi_s(s, len);
    s += len;

    s += re_match("\\d+", s, &len);
    g.hp = kt_atoi_s(s, len);
    s += len;

    // weak to
    const char* ps = s;
    {
        i32 found = re_match("weak to", s, &len);
        if (found >= 0) {
            s += found + len;
            for (; *s != ';' && *s != ')';) {
                s += re_match("\\w+", s, &len);
                i32 v = type_pool_get(pool, s, len);
                array_push(&g.weak_types, v);
                s += len;
            }
        }
        s = ps;
    }
    {
        i32 found = re_match("immune to", s, &len);
        if (found >= 0) {
            s += found + len;
            for (; *s != ';' && *s != ')';) {
                s += re_match("\\w+", s, &len);
                i32 v = type_pool_get(pool, s, len);
                array_push(&g.immune_types, v);
                s += len;
            }
        }
        s = ps;
    }

    s += re_match("\\d+", s, &len);
    g.damage = kt_atoi_s(s, len);
    s += len;

    s += re_match("\\w+", s, &len);
    g.damage_type = type_pool_get(pool, s, len);
    s += len;

    s += re_match("\\d+", s, &len);
    g.initiative = kt_atoi_s(s, len);
    s += len;

    return g;
}

static i32 group_effective_power(const group_t* g)
{
    return g->units * g->damage;
}

static i32 group_damage(const group_t* attacker, const group_t* defender)
{
    i32 damage = group_effective_power(attacker);
    for (i32 i = 0; i < defender->immune_types.len; i++) {
        if (attacker->damage_type == defender->immune_types.arr[i]) {
            return 0;
        }
    }
    for (i32 i = 0; i < defender->weak_types.len; i++) {
        if (attacker->damage_type == defender->weak_types.arr[i]) {
            return 2 * damage;
        }
    }
    return damage;
}

static fight_t fight_init(void* arena, const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);
    const char* line;
    i32 immunes_len = 0, infections_len = 0;
    b8 start_infections = FALSE;

    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        if (*line == 'I') continue;
        if (*line == 0) {
            start_infections = TRUE;
            continue;
        }
        if (start_infections) {
            infections_len += 1;
        } else {
            immunes_len += 1;
        }
    }
    kt_scanner_reset(scanner);

    group_t* groups = kt_linear_arena_array_zero(arena, group_t,
                                                 immunes_len + infections_len);
    group_t** immunes =
        kt_linear_arena_array_zero(arena, group_t*, immunes_len);
    group_t** immunes_selected =
        kt_linear_arena_array_zero(arena, group_t*, immunes_len);
    group_t** infections =
        kt_linear_arena_array_zero(arena, group_t*, infections_len);
    group_t** infections_selected =
        kt_linear_arena_array_zero(arena, group_t*, infections_len);
    start_infections = FALSE;
    immunes_len = 0, infections_len = 0;
    i32 len = 0;
    type_pool_t pool = type_pool_init(arena, 1024);

    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        if (*line == 'I') continue;
        if (*line == 0) {
            start_infections = TRUE;
            continue;
        }
        if (start_infections) {
            groups[len] = group_from(line, &pool, infections_len + 1);
            infections[infections_len++] = groups + len;
        } else {
            groups[len] = group_from(line, &pool, immunes_len + 1);
            immunes[immunes_len++] = groups + len;
        }
        len++;
    }
    kt_scanner_deinit(scanner);

    fight_t f;
    f.immunes = immunes;
    f.immunes_selected = immunes_selected;
    f.immunes_len = immunes_len;
    f.infections = infections;
    f.infections_selected = infections_selected;
    f.infections_len = infections_len;
    return f;
}

static void fight_selection_sort(group_t** gs, i32 len)
{
    for (i32 i = 0; i < len; i++) {
        i32 p = i;
        for (i32 j = i + 1; j < len; j++) {
            group_t* gp = gs[p];
            group_t* gj = gs[j];

            i32 gp_ep = group_effective_power(gp);
            i32 gj_ep = group_effective_power(gj);
            if (gj_ep > gp_ep) {
                p = j;
            } else if (gj_ep == gp_ep && gj->initiative > gp->initiative) {
                p = j;
            }
        }
        if (p != i) {
            group_t* temp = gs[p];
            gs[p] = gs[i];
            gs[i] = temp;
        }
    }
}

static void fight_attacking_sort(group_t** gs, i32 len)
{
    for (i32 i = 0; i < len; i++) {
        i32 p = i;
        for (i32 j = i + 1; j < len; j++) {
            group_t* gp = gs[p];
            group_t* gj = gs[j];
            if (gj->initiative > gp->initiative) {
                p = j;
            }
        }
        if (p != i) {
            group_t* temp = gs[p];
            gs[p] = gs[i];
            gs[i] = temp;
        }
    }
}

static void fight_selection_for(group_t** attacking, i32 attacking_len,  //
                                group_t** defending, i32 defending_len,  //
                                group_t** selected)                      //
{
    for (i32 i = 0; i < attacking_len; i++) {
        group_t* a = attacking[i];
        group_t* s = 0;
        i32 max_damage = 0;
        i32 si = -1;
        for (i32 j = 0; j < defending_len; j++) {
            if (selected[j]) continue;
            group_t* d = defending[j];
            i32 damage = group_damage(a, d);
            if (damage > max_damage) {
                max_damage = damage;
                s = d;
                si = j;
            }
        }
        a->attack = s;
        if (si >= 0) selected[si] = a;
    }
}

static void fight_target_selection(fight_t* f)
{
    fight_selection_sort(f->immunes, f->immunes_len);
    memset(f->immunes_selected, 0, sizeof(group_t*) * f->immunes_len);
    fight_selection_sort(f->infections, f->infections_len);
    memset(f->infections_selected, 0, sizeof(group_t*) * f->infections_len);

    fight_selection_for(f->immunes, f->immunes_len, f->infections,
                        f->infections_len, f->infections_selected);
    fight_selection_for(f->infections, f->infections_len, f->immunes,
                        f->immunes_len, f->immunes_selected);
}

static void fight_remove_dead(fight_t* f)
{
    {
        i32 i = 0, j = f->immunes_len - 1;
        i32 removed = 0;
        for (; i <= j;) {
            group_t* g = f->immunes[i];
            if (g->units <= 0) {
                group_t* temp = f->immunes[j];
                f->immunes[j] = f->immunes[i];
                f->immunes[i] = temp;
                j -= 1;
                removed += 1;
            } else {
                i += 1;
            }
        }
        f->immunes_len -= removed;
    }
    {
        i32 i = 0, j = f->infections_len - 1;
        i32 removed = 0;
        for (; i <= j;) {
            group_t* g = f->infections[i];
            if (g->units <= 0) {
                group_t* temp = f->infections[j];
                f->infections[j] = f->infections[i];
                f->infections[i] = temp;
                j -= 1;
                removed += 1;
            } else {
                i += 1;
            }
        }
        f->infections_len -= removed;
    }
}

static i32 group_attack(group_t* attacker)
{
    if (attacker->units > 0 && attacker->attack) {
        i32 damage = group_damage(attacker, attacker->attack);
        i32 dead = MIN(attacker->attack->units, damage / attacker->attack->hp);
        attacker->attack->units -= dead;
        return dead;
    }
    return 0;
}

static i32 fight_attacking(fight_t* f)
{
    fight_attacking_sort(f->immunes, f->immunes_len);
    fight_attacking_sort(f->infections, f->infections_len);
    i32 i = 0, j = 0;
    i32 dead = 0;
    for (;;) {
        if (i == f->immunes_len || j == f->infections_len) break;
        group_t* attacker1 = f->immunes[i];
        group_t* attacker2 = f->infections[j];
        if (attacker1->initiative > attacker2->initiative) {
            dead += group_attack(attacker1);
            i += 1;
        } else {
            dead += group_attack(attacker2);
            j += 1;
        }
    }
    for (; i < f->immunes_len; i++) {
        group_t* attacker = f->immunes[i];
        dead += group_attack(attacker);
    }
    for (; j < f->infections_len; j++) {
        group_t* attacker = f->infections[j];
        dead += group_attack(attacker);
    }
    fight_remove_dead(f);
    return dead;
}

static void fight_print(fight_t* f)
{
    DEBUG("Immune System:\n");
    if (f->immunes_len > 0) {
        for (i32 i = 0; i < f->immunes_len; i++) {
            DEBUG("units %d\n", f->immunes[i]->units);
        }
    } else {
        DEBUG("No groups remain.\n");
    }
    DEBUG("Infection:\n");
    if (f->infections_len > 0) {
        for (i32 i = 0; i < f->infections_len; i++) {
            DEBUG("units %d\n", f->infections[i]->units);
        }
    } else {
        DEBUG("No groups remain.\n");
    }
    DEBUG("\n");
}

static i32 fight_remaining_units(fight_t* f)
{
    i32 left = 0;
    for (i32 i = 0; i < f->immunes_len; i++) {
        left += f->immunes[i]->units;
    }
    for (i32 i = 0; i < f->infections_len; i++) {
        left += f->infections[i]->units;
    }
    return left;
}

static void fight_copy_and_boost(fight_t* dst, const fight_t* src, i32 v)
{
    dst->immunes_len = src->immunes_len;
    fight_attacking_sort(dst->immunes, dst->immunes_len);
    fight_attacking_sort(src->immunes, src->immunes_len);
    for (i32 i = 0; i < dst->immunes_len; i++) {
        dst->immunes[i]->units = src->immunes[i]->units;
        dst->immunes[i]->damage = src->immunes[i]->damage + v;
        dst->immunes_selected[i] = 0;
    }

    dst->infections_len = src->infections_len;
    fight_attacking_sort(dst->infections, dst->infections_len);
    fight_attacking_sort(src->infections, src->infections_len);
    for (i32 i = 0; i < dst->infections_len; i++) {
        dst->infections[i]->units = src->infections[i]->units;
        dst->infections_selected[i] = 0;
    }
}

static void fight_start(fight_t* f)
{
    for (;;) {
        if (f->immunes_len == 0 || f->infections_len == 0) break;
        fight_target_selection(f);
        i32 dead = fight_attacking(f);
        if (dead <= 0) break;
    }
}

static b8 fight_is_win(fight_t* f)
{
    return f->immunes_len > 0 && f->infections_len == 0;
}

static i32 fight_boost_to_win(void* arena, const char* input_file)
{
    fight_t templ = fight_init(arena, input_file);
    fight_t f = fight_init(arena, input_file);

    i32 boost = 1;
    for (;;) {
        fight_copy_and_boost(&f, &templ, boost);
        fight_start(&f);

        DEBUG("boost %d\n", boost);
        fight_print(&f);

        if (fight_is_win(&f)) break;
        boost += 1;
    }

    return fight_remaining_units(&f);
}

i32 winning_army_units(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    fight_t f = fight_init(arena, input_file);
    fight_start(&f);
    i32 result = fight_remaining_units(&f);
    kt_linear_arena_deinit(arena);
    return result;
}

i32 boost_to_win(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    i32 result = fight_boost_to_win(arena, input_file);
    kt_linear_arena_deinit(arena);
    return result;
}

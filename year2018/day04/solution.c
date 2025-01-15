#include <stdio.h>

#include "../lib/kt.h"

#define GUARD_CAP 512
#define RECORD_CAP 1200

typedef enum {
    record_type_begin,
    record_type_asleep,
    record_type_wakeup
} record_type_t;

typedef struct {
    int guard_id;
    char date[17];
    int timestamp;
    int minute;
    record_type_t type;
} record_t;

typedef struct {
    int id;
    int last_sleep_minute;
    int asleep[60];
} guard_t;

static int date_to_timestamp(const char* s)
{
    // ignore year
    while (*s != '-') s += 1;
    s += 1;

    int i = 0;
    while (s[i] != '-') i += 1;
    int month = kt_atoi_s(s, i);

    s += i + 1;
    i = 0;
    while (s[i] != ' ') i += 1;
    int day = kt_atoi_s(s, i);

    s += i + 1;
    i = 0;
    while (s[i] != ':') i += 1;
    int hour = kt_atoi_s(s, i);

    s += i + 1;
    int min = kt_atoi(s);

    return month * 1000000 + day * 10000 + hour * 100 + min;
}

static void record_from(const char* s, record_t* record)
{
    s += 1;
    for (int i = 0; *s != ']'; s += 1, i += 1) {
        record->date[i] = *s;
    }
    s += 2;

    record->timestamp = date_to_timestamp(record->date);
    record->minute = record->timestamp % 100;

    if (*s == 'G') {
        record->type = record_type_begin;

        while (*s != '#') s += 1;
        s += 1;
        int i = 0;
        while (s[i] != ' ') i += 1;
        record->guard_id = kt_atoi_s(s, i);
    } else if (*s == 'f') {
        record->type = record_type_asleep;
    } else {
        record->type = record_type_wakeup;
    }
}

static void sort_records(record_t* records, int len)
{
    for (int i = 0; i < len; i++) {
        int min_timestamp = records[i].timestamp;
        int min_i = i;
        for (int j = i + 1; j < len; j++) {
            int timestamp = records[j].timestamp;
            if (timestamp < min_timestamp) {
                min_timestamp = timestamp;
                min_i = j;
            }
        }
        if (min_i != i) {
            record_t temp = records[i];
            records[i] = records[min_i];
            records[min_i] = temp;
        }
    }
}

static void guard_update_asleep(guard_t* g, int wake_at)
{
    for (int i = g->last_sleep_minute; i < wake_at; i++) {
        g->asleep[i] += 1;
    }
    g->last_sleep_minute = 0;
}

static int guard_total_asleep(guard_t* g)
{
    int sum = 0;
    for (int i = 0; i < 60; i++) {
        sum += g->asleep[i];
    }
    return sum;
}

static int guard_most_asleep_minute(guard_t* g)
{
    int max = 0;
    int max_minute = 0;
    for (int i = 0; i < 60; i++) {
        if (g->asleep[i] > max) {
            max = g->asleep[i];
            max_minute = i;
        }
    }
    return max_minute;
}

static void guard_most_asleep_minute2(guard_t* g, int* max, int* minute)
{
    for (int i = 0; i < 60; i++) {
        if (g->asleep[i] > *max) {
            *max = g->asleep[i];
            *minute = i;
        }
    }
}

static void count_guards_asleep(record_t* records, int record_len,
                                guard_t* guards, int* guard_len)
{
    sort_records(records, record_len);

    guard_t* guard = 0;

    for (int i = 0; i < record_len; i++) {
        record_t record = records[i];
        if (record.type == record_type_begin) {
            if (guard && guard->last_sleep_minute > 0) {
                guard_update_asleep(guard, 60);
            }

            int found = 0;
            for (int j = 0; j < *guard_len; j++) {
                if (guards[j].id == record.guard_id) {
                    guard = guards + j;
                    guard->last_sleep_minute = 0;
                    found = 1;
                    break;
                }
            }
            if (found == 0) {
                guard = guards + *guard_len;
                guard->id = record.guard_id;
                *guard_len += 1;
            }
        } else if (record.type == record_type_asleep) {
            guard->last_sleep_minute = record.minute;
        } else if (record.type == record_type_wakeup) {
            guard_update_asleep(guard, record.minute);
        }
    }
}

static void parse_records(const char* input_file, record_t* records,
                          int* record_len)
{
    void* handle = kt_scanner_init(input_file);
    const char* line;
    while ((line = kt_scanner_next(handle, '\n')) != 0) {
        record_from(line, records + *record_len);
        *record_len += 1;
    }
    kt_scanner_deinit(handle);
}

static int find_most_sleep_minutes(guard_t* guards, int guard_len)
{
    int most_i = 0;
    int most_asleep = 0;
    for (int i = 0; i < guard_len; i++) {
        int total_asleep = guard_total_asleep(guards + i);
        if (total_asleep > most_asleep) {
            most_asleep = total_asleep;
            most_i = i;
        }
    }

    int most_asleep_minute = guard_most_asleep_minute(guards + most_i);
    int id = guards[most_i].id;

    return id * most_asleep_minute;
}

static int find_most_frequent_sleep(guard_t* guards, int guard_len)
{
    int max_v = 0;
    int max_m = 0;
    int max_i = 0;
    for (int i = 0; i < guard_len; i++) {
        int max = 0, minute = 0;
        guard_most_asleep_minute2(guards + i, &max, &minute);
        if (max > max_v) {
            max_v = max;
            max_m = minute;
            max_i = guards[i].id;
        }
    }

    return max_i * max_m;
}

int strategy1(const char* input_file)
{
    record_t records[RECORD_CAP] = {0};
    int record_len = 0;
    parse_records(input_file, records, &record_len);

    guard_t guards[GUARD_CAP] = {0};
    int guard_len = 0;
    count_guards_asleep(records, record_len, guards, &guard_len);

    return find_most_sleep_minutes(guards, guard_len);
}

int strategy2(const char* input_file)
{
    record_t records[RECORD_CAP] = {0};
    int record_len = 0;
    parse_records(input_file, records, &record_len);

    guard_t guards[GUARD_CAP] = {0};
    int guard_len = 0;
    count_guards_asleep(records, record_len, guards, &guard_len);

    return find_most_frequent_sleep(guards, guard_len);
}

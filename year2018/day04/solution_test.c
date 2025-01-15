#include "solution.c"

#include <stdio.h>
#include <string.h>

#include "../lib/test.h"

TEST(test_record_from)
{
    {
        const char* s = "[1518-11-01 23:58] Guard #99 begins shift";
        record_t record = {0};
        record_from(s, &record);
        EXPECT(record.guard_id == 99, "expect guard_id = 99, got %d",
               record.guard_id);
        EXPECT(strcmp(record.date, "1518-11-01 23:58") == 0,
               "expect date = 1518-11-01 23:58, got %s", record.date);
        EXPECT(record.timestamp == 11012358,
               "expect timestamp = 11012358, got %d", record.timestamp);
        EXPECT(record.type == record_type_begin, "expect type = %d, got %d",
               record_type_begin, record.type);
    }
    {
        const char* s = "[1518-11-01 00:05] falls asleep";
        record_t record = {0};
        record_from(s, &record);
        EXPECT(record.guard_id == 0, "expect guard_id = 0, got %d",
               record.guard_id);
        EXPECT(strcmp(record.date, "1518-11-01 00:05") == 0,
               "expect date = 1518-11-01 00:05, got %s", record.date);
        EXPECT(record.timestamp == 11010005,
               "expect timestamp = 11010005, got %d", record.timestamp);
        EXPECT(record.type == record_type_asleep, "expect type = %d, got %d",
               record_type_asleep, record.type);
    }
    {
        const char* s = "[1518-11-03 00:29] wakes up";
        record_t record = {0};
        record_from(s, &record);
        EXPECT(record.guard_id == 0, "expect guard_id = 0, got %d",
               record.guard_id);
        EXPECT(strcmp(record.date, "1518-11-03 00:29") == 0,
               "expect date = 1518-11-03 00:29, got %s", record.date);
        EXPECT(record.timestamp == 11030029,
               "expect timestamp = 11030029, got %d", record.timestamp);
        EXPECT(record.type == record_type_wakeup, "expect type = %d, got %d",
               record_type_wakeup, record.type);
    }
}

TEST(test_sort_records)
{
    const char* s[13] = {
        "[1518-11-01 00:25] wakes up",
        "[1518-11-01 00:00] Guard #10 begins shift",
        "[1518-11-01 00:05] falls asleep",
        "[1518-11-01 00:30] falls asleep",
        "[1518-11-01 23:58] Guard #99 begins shift",
        "[1518-11-01 00:55] wakes up",
        "[1518-11-02 00:40] falls asleep",
        "[1518-11-02 00:50] wakes up",
        "[1518-11-03 00:24] falls asleep",
        "[1518-11-03 00:05] Guard #10 begins shift",
        "[1518-11-03 00:29] wakes up",
        "[1518-11-04 00:02] Guard #99 begins shift",
        "[1518-11-04 00:36] falls asleep",
    };
    record_t records[13] = {0};

    for (int i = 0; i < 13; i++) {
        record_from(s[i], records + i);
    }

    sort_records(records, 13);

    for (int i = 1; i < 13; i++) {
        EXPECT(records[i - 1].timestamp < records[i].timestamp,
               "expect chronological order, prev = %s, curr = %s",
               records[i - 1].date, records[i].date);
    }
}

TEST(test_find_most_sleep_minutes)
{
#define LEN 17
    const char* s[] = {
        "[1518-11-01 00:00] Guard #10 begins shift",
        "[1518-11-01 00:05] falls asleep",
        "[1518-11-01 00:25] wakes up",
        "[1518-11-01 00:30] falls asleep",
        "[1518-11-01 00:55] wakes up",
        "[1518-11-01 23:58] Guard #99 begins shift",
        "[1518-11-02 00:40] falls asleep",
        "[1518-11-02 00:50] wakes up",
        "[1518-11-03 00:05] Guard #10 begins shift",
        "[1518-11-03 00:24] falls asleep",
        "[1518-11-03 00:29] wakes up",
        "[1518-11-04 00:02] Guard #99 begins shift",
        "[1518-11-04 00:36] falls asleep",
        "[1518-11-04 00:46] wakes up",
        "[1518-11-05 00:03] Guard #99 begins shift",
        "[1518-11-05 00:45] falls asleep",
        "[1518-11-05 00:55] wakes up",
    };
    record_t records[LEN] = {0};

    for (int i = 0; i < LEN; i++) {
        record_from(s[i], records + i);
    }

    guard_t guards[LEN] = {0};
    int guard_len;
    count_guards_asleep(records, LEN, guards, &guard_len);

    int got = find_most_sleep_minutes(guards, guard_len);
    EXPECT(got == 240, "expect 240, got %d", got);
#undef LEN
}

TEST(test_find_most_frequent_sleep)
{
#define LEN 17
    const char* s[] = {
        "[1518-11-01 00:00] Guard #10 begins shift",
        "[1518-11-01 00:05] falls asleep",
        "[1518-11-01 00:25] wakes up",
        "[1518-11-01 00:30] falls asleep",
        "[1518-11-01 00:55] wakes up",
        "[1518-11-01 23:58] Guard #99 begins shift",
        "[1518-11-02 00:40] falls asleep",
        "[1518-11-02 00:50] wakes up",
        "[1518-11-03 00:05] Guard #10 begins shift",
        "[1518-11-03 00:24] falls asleep",
        "[1518-11-03 00:29] wakes up",
        "[1518-11-04 00:02] Guard #99 begins shift",
        "[1518-11-04 00:36] falls asleep",
        "[1518-11-04 00:46] wakes up",
        "[1518-11-05 00:03] Guard #99 begins shift",
        "[1518-11-05 00:45] falls asleep",
        "[1518-11-05 00:55] wakes up",
    };
    record_t records[LEN] = {0};

    for (int i = 0; i < LEN; i++) {
        record_from(s[i], records + i);
    }

    guard_t guards[LEN] = {0};
    int guard_len;
    count_guards_asleep(records, LEN, guards, &guard_len);

    int got = find_most_frequent_sleep(guards, guard_len);
    EXPECT(got == 4455, "expect 4455, got %d", got);
#undef LEN
}

TEST_MAIN(test_record_from, test_sort_records, test_find_most_sleep_minutes,
          test_find_most_frequent_sleep)

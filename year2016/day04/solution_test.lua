local test = require('libs.test')
local s = require('day04.solution')

test('_split_row', function(a)
    local testcases = {
        {
            input = 'aaaaa-bbb-z-y-x-123[abxyz]',
            expect = { 'aaaaa-bbb-z-y-x', 123, 'abxyz', },
        },
        {
            input = 'a-b-c-d-e-f-g-h-987[abcde]',
            expect = { 'a-b-c-d-e-f-g-h', 987, 'abcde', },
        },
        {
            input = 'totally-real-room-200[decoy]',
            expect = { 'totally-real-room', 200, 'decoy', },
        },
    }

    for _, tt in ipairs(testcases) do
        local name, room_id, checksum = s._split_row(tt.input)
        a.equal(name, tt.expect[1])
        a.equal(room_id, tt.expect[2])
        a.equal(checksum, tt.expect[3])
    end
end)

test('_count_letters', function(a)
    local testcases = {
        {
            input = 'aaaaa-bbb-z-y-x',
            expect = 'abxyz',
        },
        {
            input = 'a-b-c-d-e-f-g-h',
            expect = 'abcde',
        },
        {
            input = 'not-a-real-room',
            expect = 'oarel',
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s._count_letters(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('_is_real_room', function(a)
    local testcases = {
        {
            input = 'aaaaa-bbb-z-y-x-123[abxyz]',
            expect = { true, 123, },
        },
        {
            input = 'a-b-c-d-e-f-g-h-987[abcde]',
            expect = { true, 987, },
        },
        {
            input = 'not-a-real-room-404[oarel]',
            expect = { true, 404, },
        },
        {
            input = 'totally-real-room-200[decoy]',
            expect = { false, 200, },
        },
    }

    for _, tt in ipairs(testcases) do
        local is_real, room_id = s._is_real_room(tt.input)
        a.equal(is_real, tt.expect[1])
        a.equal(room_id, tt.expect[2])
    end
end)

test('sum_real_room_ids', function(a)
    local input = [[
aaaaa-bbb-z-y-x-123[abxyz]
a-b-c-d-e-f-g-h-987[abcde]
not-a-real-room-404[oarel]
totally-real-room-200[decoy]
]]
    local got = s.sum_real_room_ids(input)
    a.equal(got, 1514)
end)

test('_decrypt_name', function(a)
    local got = s._decrypt_name('qzmt-zixmtkozy-ivhz', 343)
    a.equal(got, 'very encrypted name')
end)

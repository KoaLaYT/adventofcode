local test = require('libs.test')
local s = require('day04.solution')

test('is_valid', function(a)
    local testcases = {
        {
            input = 'aa bb cc dd ee',
            expect = true,
        },
        {
            input = 'aa bb cc dd aa',
            expect = false,
        },
        {
            input = 'aa bb cc dd aaa',
            expect = true,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.is_valid(tt.input)
        a.equal(got, tt.expect,
            string.format('%s, got: %s, expect: %s', tt.input, tostring(got), tostring(tt.expect)));
    end
end)

test('is_valid_v2', function(a)
    local testcases = {
        {
            input = 'abcde fghij',
            expect = true,
        },
        {
            input = 'abcde xyz ecdab',
            expect = false,
        },
        {
            input = 'a ab abc abd abf abj',
            expect = true,
        },
        {
            input = 'iiii oiii ooii oooi oooo',
            expect = true,
        },
        {
            input = 'oiii ioii iioi iiio',
            expect = false,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.is_valid_v2(tt.input)
        a.equal(got, tt.expect,
            string.format('%s, got: %s, expect: %s', tt.input, tostring(got), tostring(tt.expect)));
    end
end)

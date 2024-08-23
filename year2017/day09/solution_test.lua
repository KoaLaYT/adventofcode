local test = require('libs.test')
local s = require('day09.solution')

test('group_score', function(a)
    local testcases = {
        {
            input = '{}',
            expect = 1,
        },
        {
            input = '{{{}}}',
            expect = 6,
        },
        {
            input = '{{},{}}',
            expect = 5,
        },
        {
            input = '{{{},{},{{}}}}',
            expect = 16,
        },
        {
            input = '{<a>,<a>,<a>,<a>}',
            expect = 1,
        },
        {
            input = '{{<ab>},{<ab>},{<ab>},{<ab>}}',
            expect = 9,
        },
        {
            input = '{{<!!>},{<!!>},{<!!>},{<!!>}}',
            expect = 9,
        },
        {
            input = '{{<a!>},{<a!>},{<a!>},{<ab>}}',
            expect = 3,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.group_score(tt.input)
        a.equal(got, tt.expect,
            string.format('%s, expect: %d, got: %d', tt.input, tt.expect, got))
    end
end)

test('count_garbage', function(a)
    local testcases = {
        {
            input = '{<>}',
            expect = 0,
        },
        {
            input = '{<random characters>}',
            expect = 17,
        },
        {
            input = '{<<<<>}',
            expect = 3,
        },
        {
            input = '{<{!>}>}',
            expect = 2,
        },
        {
            input = '{<!!>}',
            expect = 0,
        },
        {
            input = '{<!!!>>}',
            expect = 0,
        },
        {
            input = '{<{o"i!a,<{i<a>}',
            expect = 10,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.count_garbage(tt.input)
        a.equal(got, tt.expect,
            string.format('%s, expect: %d, got: %d', tt.input, tt.expect, got))
    end
end)

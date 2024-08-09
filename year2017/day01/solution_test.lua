local test = require('libs.test')
local s = require('day01.solution')

test('count_sum', function(a)
    local testcases = {
        {
            input = '1122',
            expect = 3,
        },
        {
            input = '1111',
            expect = 4,
        },
        {
            input = '1234',
            expect = 0,
        },
        {
            input = '91212129',
            expect = 9,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.count_sum(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('count_sum_v2', function(a)
    local testcases = {
        {
            input = '1212',
            expect = 6,
        },
        {
            input = '1221',
            expect = 0,
        },
        {
            input = '123425',
            expect = 4,
        },
        {
            input = '123123',
            expect = 12,
        },
        {
            input = '12131415',
            expect = 4,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.count_sum_v2(tt.input)
        a.equal(got, tt.expect)
    end
end)

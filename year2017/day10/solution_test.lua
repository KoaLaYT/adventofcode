local test = require('libs.test')
local s = require('day10.solution')

test('knot_hash', function(a)
    local input = { 3, 4, 1, 5, }
    local got = s.knot_hash(input, 5)
    a.equal(got, 12)
end)

test('full_knot_hash', function(a)
    local testcases = {
        {
            input = '',
            expect = 'a2582a3a0e66e6e86e3812dcb672a272',
        },
        {
            input = 'AoC 2017',
            expect = '33efeb34ea91902bb2f59c9920caa6cd',
        },
        {
            input = '1,2,3',
            expect = '3efbe78a8d82f29979031a4aa0b16a9d',
        },
        {
            input = '1,2,4',
            expect = '63960835bcdc130f0b66d7ff4f6a5a8e',
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.full_knot_hash(tt.input)
        a.equal(got, tt.expect)
    end
end)

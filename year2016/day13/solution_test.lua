local test = require('libs.test')
local s = require('day13.solution')

test('count_bits', function(a)
    local testcases = {
        {
            input = 1,
            expect = 1,
        },
        {
            input = 2,
            expect = 1,
        },
        {
            input = 3,
            expect = 2,
        },
        {
            input = 26348,
            expect = 9,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.count_bits(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('shortest_route_to', function(a)
    local got = s.shortest_route_to(7, 4, 10)
    a.equal(got, 11)
end)

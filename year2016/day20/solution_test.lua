local test = require('libs.test')
local s = require('day20.solution')

test('IpRange:intersect', function(a)
    local testcases = {
        {
            input = { { 1, 5, }, { 0, 4, }, },
            expect = true,
        },
    }

    for _, tt in ipairs(testcases) do
        local r1 = s.IpRange:new(unpack(tt.input[1]))
        local r2 = s.IpRange:new(unpack(tt.input[2]))
        a.equal(r1:intersect(r2), tt.expect)
    end
end)

test('lowest_allowed_ip', function(a)
    local testcases = {
        {
            input = [[
5-8
0-2
4-7
]],
            expect = 3,
        },
        {
            input = [[
2-3
1-4
2-5
7-8
0-4
]],
            expect = 6,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.lowest_allowed_ip(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('total_allowed_ips', function(a)
    local testcases = {
        {
            input = [[
5-8
0-2
4-7
]],
            expect = 2,
        },
        {
            input = [[
2-3
1-4
2-5
7-8
0-4
]],
            expect = 2,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.total_allowed_ips(tt.input, 10)
        a.equal(got, tt.expect)
    end
end)

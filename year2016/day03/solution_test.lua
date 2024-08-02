local test = require('libs.test')
local s = require('day03.solution')

test('parse_triangle', function(a)
    local testcases = {
        {
            input = '  883  357  185',
            expect = { 883, 357, 185, },
        },
        {
            input = '   536  884   48',
            expect = { 536, 884, 48, },
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.parse_triangle(tt.input)
        a.deep_equal(got, tt.expect)
    end
end)

test('is_possible_triangle', function(a)
    local testcases = {
        {
            input = { 5, 10, 25, },
            expect = false,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.is_possible_triangle(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('count_possible_triangles', function(a)
    local testcases = {
        {
            input = '5 10 25\n\n\n\t6 8 10',
            expect = 1,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.count_possible_triangles(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('count_possible_triangles_vertically', function(a)
    local testcases = {
        {
            input = [[
    6   2   3
    8   1   4
    10  3   5
]],
            expect = 2,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.count_possible_triangles_vertically(tt.input)
        a.equal(got, tt.expect)
    end
end)

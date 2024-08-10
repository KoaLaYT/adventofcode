local test = require('libs.test')
local s = require('day03.solution')

test('distance', function(a)
    local testcases = {
        { input = 1,    expect = 0, },
        { input = 12,   expect = 3, },
        { input = 23,   expect = 2, },
        { input = 1024, expect = 31, },
    }

    for _, tt in ipairs(testcases) do
        local got = s.distance(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('value', function(a)
    local testcases = {
        { input = 1,   expect = 2, },
        { input = 800, expect = 806, },
    }

    for _, tt in ipairs(testcases) do
        local got = s.value(tt.input)
        a.equal(got, tt.expect)
    end
end)

local test = require('libs.test')
local s = require('day19.solution')

test('get_all_present', function(a)
    local testcases = {
        { input = 5, expect = 3, },
        { input = 7, expect = 7, },
    }
    for _, tt in ipairs(testcases) do
        local got = s.get_all_present(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('get_all_present_v2', function(a)
    local testcases = {
        { input = 5,      expect = 2, },
        { input = 6,      expect = 3, },
        { input = 100000, expect = 40951, },
    }
    for _, tt in ipairs(testcases) do
        local got = s.get_all_present_v2(tt.input)
        a.equal(got, tt.expect)
    end
end)

local test = require('libs.test')
local s = require('day18.solution')

test('count_safe_tiles', function(a)
    local testcases = {
        { input = { '..^^.', 3, },       expect = 6, },
        { input = { '.^^.^.^^^^', 10, }, expect = 38, },
    }

    for _, tt in ipairs(testcases) do
        local got = s.count_safe_tiles(unpack(tt.input))
        a.equal(got, tt.expect)
    end
end)

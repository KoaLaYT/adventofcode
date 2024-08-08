local test = require('libs.test')
local s = require('day22.solution')

test('Node:new', function(a)
    local testcases = {
        {
            input = '/dev/grid/node-x0-y0     85T   67T    18T   78%',
            expect = setmetatable({
                x = 0,
                y = 0,
                size = 85,
                used = 67,
                avail = 18,
            }, s.Node),
        },
        {
            input = '/dev/grid/node-x1-y13   502T  498T     4T   99%',
            expect = setmetatable({
                x = 1,
                y = 13,
                size = 502,
                used = 498,
                avail = 4,
            }, s.Node),
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.Node:new(tt.input)
        a.equal(tostring(got), tostring(tt.expect))
    end
end)

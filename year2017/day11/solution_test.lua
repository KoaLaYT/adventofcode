local test = require('libs.test')
local s = require('day11.solution')

test('step_away', function(a)
    local testcases = {
        {
            input = 'ne,ne,ne',
            expect = 3,
        },
        {
            input = 'ne,ne,sw,sw',
            expect = 0,
        },
        {
            input = 'ne,ne,s,s',
            expect = 2,
        },
        {
            input = 'se,sw,se,sw,sw',
            expect = 3,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.step_away(tt.input)
        a.equal(got, tt.expect)
    end
end)

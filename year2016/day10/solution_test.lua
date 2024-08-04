local test = require('libs.test')
local s = require('day10.solution')

test('Factory:find_chips', function(a)
    local instructions = [[
value 5 goes to bot 2
bot 2 gives low to bot 1 and high to bot 0
value 3 goes to bot 1
bot 1 gives low to output 1 and high to bot 0
bot 0 gives low to output 2 and high to output 0
value 2 goes to bot 2
]]

    local testcases = {
        {
            input = { 5, 2, },
            expect = '2',
        },
        {
            input = { 3, 2, },
            expect = '1',
        },
        {
            input = { 3, 5, },
            expect = '0',
        },
    }

    for _, tt in ipairs(testcases) do
        local f = s.Factory:new(instructions)
        local got = f:find_chips(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('Factory:multiply_outputs', function(a)
    local instructions = [[
value 5 goes to bot 2
bot 2 gives low to bot 1 and high to bot 0
value 3 goes to bot 1
bot 1 gives low to output 1 and high to bot 0
bot 0 gives low to output 2 and high to output 0
value 2 goes to bot 2
]]

    local f = s.Factory:new(instructions)
    local got = f:multiply_outputs({ '0', '1', '2', })
    a.equal(got, 30)
end)

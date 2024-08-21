local test = require('libs.test')
local s = require('day08.solution')

test('Instruction:new', function(a)
    local testcases = {
        {
            input = 'hkt inc -511 if mdk == 0',
            expect = { 'hkt', 1, -511, 'mdk', 5, 0, },
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.Instruction:new(tt.input)
        a.equal(got.modify_reg, tt.expect[1])
        a.equal(got.action, tt.expect[2])
        a.equal(got.amount, tt.expect[3])
        a.equal(got.cond_reg, tt.expect[4])
        a.equal(got.cond_check, tt.expect[5])
        a.equal(got.cond_val, tt.expect[6])
    end
end)

test('largest_after_execution', function(a)
    local input = [[
b inc 5 if a > 1
a inc 1 if b < 5
c dec -10 if a >= 1
c inc -20 if c == 10]]

    local got = s.largest_after_execution(input)
    a.equal(got, 1)
end)

test('largest_during_execution', function(a)
    local input = [[
b inc 5 if a > 1
a inc 1 if b < 5
c dec -10 if a >= 1
c inc -20 if c == 10]]

    local got = s.largest_during_execution(input)
    a.equal(got, 10)
end)

local test = require('libs.test')
local s = require('day05.solution')

test('jump_steps', function(a)
    local input = { 0, 3, 0, 1, -3, }
    local got = s.jump_steps(input)
    a.equal(got, 5)
end)

test('jump_steps_v2', function(a)
    local input = { 0, 3, 0, 1, -3, }
    local got = s.jump_steps_v2(input)
    a.equal(got, 10)
end)

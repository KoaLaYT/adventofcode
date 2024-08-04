local test = require('libs.test')
local s = require('day12.solution')

test('Computer', function(a)
    local input = [[
cpy 41 a
inc a
inc a
dec a
jnz a 2
dec a
]]
    local computer = s.Computer:new(input)
    computer:run()
    a.equal(computer:register('a'), 42)
end)

local test = require('libs.test')
local s = require('day23.solution')

test('Computer:run', function(a)
    local input = [[
cpy 2 a
tgl a
tgl a
tgl a
cpy 1 a
dec a
dec a]]
    local computer = s.Computer:new(input)
    computer:run()
    a.equal(computer:register('a'), 3)
end)

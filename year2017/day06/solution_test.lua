local test = require('libs.test')
local s = require('day06.solution')

test('redistribution_cycles', function(a)
    local input = { 0, 2, 7, 0, }
    local cycle, loop = s.redistribution_cycles(input)
    a.equal(cycle, 5)
    a.equal(loop, 4)
end)

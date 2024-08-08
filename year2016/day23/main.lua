local h = require('libs.helper')
local s = require('day23.solution')

local input = h.getinput()

h.solve('Part One', function()
    local computer = s.Computer:new(input)
    computer:set_register('a', 7)
    computer:run()
    return computer:register('a')
end)

h.solve('Part Two', function()
    local computer = s.Computer:new(input)
    computer:set_register('a', 12)
    computer:run()
    return computer:register('a')
end)

local h = require('libs.helper')
local s = require('day12.solution')

local input = h.getinput()

h.solve('Part One', function()
    local computer = s.Computer:new(input)
    computer:run()
    return computer:register('a')
end)

h.solve('Part One', function()
    local computer = s.Computer:new(input)
    computer:set_register('c', 1)
    computer:run()
    return computer:register('a')
end)

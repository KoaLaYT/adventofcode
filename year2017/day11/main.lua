local h = require('libs.helper')
local s = require('day11.solution')

local input = h.getinput()

h.solve('Part One', function()
    return s.step_away(input)
end)

h.solve('Part Two', function()
    return s.furthest(input)
end)

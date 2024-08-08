local h = require('libs.helper')
local s = require('day22.solution')

local input = h.getinput()

h.solve('Part One', function()
    return s.viable_pairs(input)
end)

h.solve('Part Two', function()
    return s.fewest_step(input)
end)

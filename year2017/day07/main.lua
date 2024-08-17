local h = require('libs.helper')
local s = require('day07.solution')

local input = h.getinput()

h.solve('Part One', function()
    return s.find_bottom(input)
end)

h.solve('Part Two', function()
    return s.find_inbalance(input)
end)

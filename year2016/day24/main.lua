local h = require('libs.helper')
local s = require('day24.solution')

local input = h.getinput()

h.solve('Part One', function()
    return s.shortest_route(input)
end)

h.solve('Part Two', function()
    return s.shortest_route(input, true)
end)

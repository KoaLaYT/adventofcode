local h = require('libs.helper')
local s = require('day13.solution')

h.solve('Part One', function()
    return s.shortest_route_to(31, 39, 1350)
end)

h.solve('Part Two', function()
    return s.visited_locations_by(50, 1350)
end)

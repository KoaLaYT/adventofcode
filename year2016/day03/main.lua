local h = require('libs.helper')
local s = require('day03.solution')

h.solve('Part One', function()
    local input = h.getinput()
    return s.count_possible_triangles(input)
end)

h.solve('Part Two', function()
    local input = h.getinput()
    return s.count_possible_triangles_vertically(input)
end)

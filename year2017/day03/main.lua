local h = require('libs.helper')
local s = require('day03.solution')

local input = 368078

h.solve('Part One', function()
    return s.distance(input)
end)

h.solve('Part Two', function()
    return s.value(input)
end)

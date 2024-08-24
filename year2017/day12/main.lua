local h = require('libs.helper')
local s = require('day12.solution')

local input = h.getinput()

h.solve('Part One', function()
    return s.contact_zero_programs(input)
end)

h.solve('Part Two', function()
    return s.groups(input)
end)

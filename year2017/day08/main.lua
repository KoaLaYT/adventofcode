local h = require('libs.helper')
local s = require('day08.solution')

local input = h.getinput()

h.solve('Part One', function()
    return s.largest_after_execution(input)
end)

h.solve('Part Two', function()
    return s.largest_during_execution(input)
end)

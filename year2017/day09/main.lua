local h = require('libs.helper')
local s = require('day09.solution')

local input = h.getinput()

h.solve('Part One', function()
    return s.group_score(input)
end)

h.solve('Part Two', function()
    return s.count_garbage(input)
end)

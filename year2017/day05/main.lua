local h = require('libs.helper')
local s = require('day05.solution')

local input = h.getinput()
local list = s.parse_input(input)

h.solve('Part One', function()
    return s.jump_steps(list)
end)

h.solve('Part Two', function()
    return s.jump_steps_v2(list)
end)

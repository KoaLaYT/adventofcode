local h = require('libs.helper')
local s = require('day06.solution')

h.solve('Part One', function()
    local input = h.getinput()
    return s.correct_error(input)
end)

h.solve('Part Two', function()
    local input = h.getinput()
    return s.correct_error_v2(input)
end)

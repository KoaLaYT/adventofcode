local h = require('libs.helper')
local s = require('day10.solution')

local input = h.getinput()

h.solve('Part One', function()
    local f = s.Factory:new(input)
    return f:find_chips({ 61, 17, })
end)

h.solve('Part Two', function()
    local f = s.Factory:new(input)
    return f:multiply_outputs({ '0', '1', '2', })
end)

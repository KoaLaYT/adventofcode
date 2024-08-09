local h = require('libs.helper')
local s = require('day25.solution')

local input = h.getinput()

h.solve('Part One', function()
    local computer = s.Computer:new(input)
    return computer:find_right_signal()
end)

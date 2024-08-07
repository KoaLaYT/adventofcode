local h = require('libs.helper')
local s = require('day20.solution')

local input = h.getinput()

h.solve('Part One', function()
    return s.lowest_allowed_ip(input)
end)

h.solve('Part Two', function()
    return s.total_allowed_ips(input, 2 ^ 32)
end)

local h = require('libs.helper')
local s = require('day02.solution')

local input = h.getinput()

h.solve('Part One', function()
    return s.checksum(input)
end)

h.solve('Part Two', function()
    return s.checksum_v2(input)
end)

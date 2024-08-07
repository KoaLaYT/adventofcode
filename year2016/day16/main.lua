local h = require('libs.helper')
local s = require('day16.solution')

local input = '00101000101111010'

h.solve('Part One', function()
    return s.full_disk(input, 272)
end)

h.solve('Part Two', function()
    return s.full_disk(input, 35651584)
end)

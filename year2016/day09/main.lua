local h = require('libs.helper')
local s = require('day09.solution')

local input = h.getinput()
input = input:sub(1, #input - 1)

h.solve('Part One', function()
    return s.decompressed_length(input)
end)

h.solve('Part Two', function()
    return s.decompressed_length_v2(input)
end)

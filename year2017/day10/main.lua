local h = require('libs.helper')
local s = require('day10.solution')

local input = { 76, 1, 88, 148, 166, 217, 130, 0, 128, 254, 16, 2, 130, 71, 255, 229, }
local input_str = '76,1,88,148,166,217,130,0,128,254,16,2,130,71,255,229'

h.solve('Part One', function()
    return s.knot_hash(input)
end)

h.solve('Part Two', function()
    return s.full_knot_hash(input_str)
end)

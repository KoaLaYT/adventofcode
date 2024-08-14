local h = require('libs.helper')
local s = require('day06.solution')

local input = {
    11, 11, 13, 7, 0,
    15, 5, 5, 4, 4,
    1, 1, 7, 1, 15, 11,
}

local cycle, loop = s.redistribution_cycles(input)

h.solve('Part One', function()
    return cycle
end)

h.solve('Part Two', function()
    return loop
end)

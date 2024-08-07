local h = require('libs.helper')
local s = require('day18.solution')

local first_row = '.^.^..^......^^^^^...^^^...^...^....^^.^...^.^^^^....^...^^.^^^...^^^^.^^.^.^^..^.^^^..^^^^^^.^^^..^'

h.solve('Part One', function()
    return s.count_safe_tiles(first_row, 40)
end)

h.solve('Part Two', function()
    return s.count_safe_tiles(first_row, 400000)
end)

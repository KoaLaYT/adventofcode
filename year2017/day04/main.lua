local h = require('libs.helper')
local s = require('day04.solution')

local input = h.getinput()

h.solve('Part One', function()
    return s.count_valid_passphrases(input)
end)

h.solve('Part Two', function()
    return s.count_valid_passphrases(input, true)
end)

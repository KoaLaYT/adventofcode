local h = require('libs.helper')
local s = require('day21.solution')

local input = h.getinput()

h.solve('Part One', function()
    return s.scramble_password('abcdefgh', input)
end)

h.solve('Part Two', function()
    return s.descramble_password('fbgdceah', input)
end)

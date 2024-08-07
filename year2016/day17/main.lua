local h = require('libs.helper')
local s = require('day17.solution')

local passcode = 'edjrjqaa'

h.solve('Part One', function()
    return s.shortest_path(passcode)
end)

h.solve('Part Two', function()
    return s.longest_path(passcode)
end)

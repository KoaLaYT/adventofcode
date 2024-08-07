local h = require('libs.helper')
local s = require('day19.solution')

local input = 3014387

h.solve('Part One', function()
    return s.get_all_present(input)
end)

h.solve('Part Two', function()
    return s.get_all_present_v2(input)
end)

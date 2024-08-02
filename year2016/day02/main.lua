local h = require('libs.helper')
local s = require('day02.solution')

h.solve('Part One', function()
    local input = h.getinput()
    local keypad = s.Keypad:new()
    return keypad:get_code(input)
end)

h.solve('Part Two', function()
    local input = h.getinput()
    local keypad = s.BathroomKeypad:new()
    return keypad:get_code(input)
end)

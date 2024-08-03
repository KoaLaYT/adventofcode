local h = require('libs.helper')
local s = require('day08.solution')

h.solve('Part One', function()
    local input = h.getinput()
    local screen = s.Screen:new(6, 50)
    screen:update(input)
    return screen:litted()
end)

h.solve('Part Two', function()
    local input = h.getinput()
    local screen = s.Screen:new(6, 50)
    screen:update(input)
    return '\n' .. screen:reveal_code()
end)

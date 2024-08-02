local h = require('libs.helper')
local s = require('day01.solution')

h.solve('Part One', function()
    local input = h.getinput()
    local human = s.Human:new()

    local instructions = s.parse_instructions(input)
    human:walks(instructions)

    return human:distance()
end)

h.solve('Part Two', function()
    local input = h.getinput()
    local human = s.Human:new()

    local instructions = s.parse_instructions(input)
    human:walks(instructions, { ['0,0'] = 1, })

    return human:distance()
end)

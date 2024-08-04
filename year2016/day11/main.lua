local h = require('libs.helper')
local s = require('day11.solution')

h.solve('Part One', function()
    local init_state = s.State:new({
        {
            microchips = { 'thulium', },
            generators = { 'plutonium', 'strontium', 'thulium', },
        },
        {
            microchips = { 'plutonium', 'strontium', },
            generators = {},
        },
        {
            microchips = { 'promethium', 'ruthenium', },
            generators = { 'promethium', 'ruthenium', },
        },
        {
            microchips = {},
            generators = {},
        },
    })
    return s.min_steps(init_state)
end)

h.solve('Part Two', function()
    local init_state = s.State:new({
        {
            microchips = { 'dilithium', 'elerium', 'thulium', },
            generators = { 'dilithium', 'elerium', 'plutonium', 'strontium', 'thulium', },
        },
        {
            microchips = { 'plutonium', 'strontium', },
            generators = {},
        },
        {
            microchips = { 'promethium', 'ruthenium', },
            generators = { 'promethium', 'ruthenium', },
        },
        {
            microchips = {},
            generators = {},
        },
    })
    return s.min_steps(init_state)
end)

local test = require('libs.test')
local s = require('day11.solution')

test('State:key', function(a)
    local state = s.State:new({
        {
            microchips = { 'H', 'L', },
            generators = {},
        },
        {
            microchips = {},
            generators = { 'H', },
        },
        {
            microchips = {},
            generators = { 'L', },
        },
        {
            microchips = {},
            generators = {},
        },
    })
    local expect = [[
 4,0M,0G
 3,0M,1G
 2,0M,1G
E1,2M,0G]]
    a.equal(state:key(), expect)
end)

test('min_steps', function(a)
    local init_state = s.State:new({
        {
            microchips = { 'H', 'L', },
            generators = {},
        },
        {
            microchips = {},
            generators = { 'H', },
        },
        {
            microchips = {},
            generators = { 'L', },
        },
        {
            microchips = {},
            generators = {},
        },
    })

    a.equal(s.min_steps(init_state), 11)
end)

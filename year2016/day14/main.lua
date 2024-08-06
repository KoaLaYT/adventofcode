local h = require('libs.helper')
local s = require('day14.solution')

local salt = 'qzyelonm'

h.solve('Part One', function()
    local g = s.Generator:new(salt)
    return g:index(64)
end)

h.solve('Part Two', function()
    local g = s.Generator:new(salt)
    return g:index_v2(64)
end)

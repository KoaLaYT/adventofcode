local h = require('libs.helper')
local s = require('day21.solution')

local input = h.getinput()

h.solve('Part One', function()
  return s.expand(input, 5)
end)

h.solve('Part Two', function()
  return s.expand(input, 18)
end)

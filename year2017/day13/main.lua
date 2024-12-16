local h = require('libs.helper')
local s = require('day13.solution')

local input = h.getinput()

h.solve('Part One', function()
  return s.travel(input)
end)

h.solve('Part Two', function()
  return s.fewest_uncaught(input)
end)

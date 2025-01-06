local h = require('libs.helper')
local s = require('day24.solution')

local input = h.getinput()

h.solve('Part One', function()
  return s.strongest(input)
end)

h.solve('Part Two', function()
  return s.longest_strongest(input)
end)

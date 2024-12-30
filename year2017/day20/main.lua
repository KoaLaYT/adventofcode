local h = require('libs.helper')
local s = require('day20.solution')

local input = h.getinput()

h.solve('Part One', function()
  return s.closest(input)
end)

h.solve('Part Two', function()
  return s.left(input)
end)

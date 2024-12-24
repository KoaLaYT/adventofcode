local h = require('libs.helper')
local s = require('day19.solution')

local input = h.getinput()

h.solve('Part One', function()
  return s.Route:new(input):letters()
end)

h.solve('Part Two', function()
  return s.Route:new(input):steps()
end)

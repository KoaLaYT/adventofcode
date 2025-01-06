local h = require('libs.helper')
local s = require('day22.solution')

local input = h.getinput()

h.solve('Part One', function()
  return s.Virus:new(input):infected_after(10000)
end)

h.solve('Part Two', function()
  return s.Virus:new(input):evolved_infected_after(10000000)
end)

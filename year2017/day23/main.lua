local h = require('libs.helper')
local s = require('day23.solution')

local input = h.getinput()

h.solve('Part One', function()
  return s.Processor:new(input):mul_invoked()
end)

h.solve('Part Two', function()
  return s.Processor:new(input):reverse_asm()
end)

local h = require('libs.helper')
local s = require('day18.solution')

local input = h.getinput()

h.solve('Part One', function()
  local tablet = s.Tablet:new(input)
  return tablet:first_rcv_nonzero()
end)

h.solve('Part Two', function()
  return s.run_two_tablets(input)
end)

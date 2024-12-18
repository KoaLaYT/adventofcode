local h = require('libs.helper')
local s = require('day17.solution')

local input = 363;

h.solve('Part One', function()
  return s.value_after(input, 2017);
end)

h.solve('Part Two', function()
  return s.value_after_zero(input, 50000000);
end)

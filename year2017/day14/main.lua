local h = require('libs.helper')
local s = require('day14.solution')

local key = 'hfdlxzhv'

h.solve('Part One', function()
  return s.used_squares(key)
end)

h.solve('Part Two', function()
  return s.count_regions(key)
end)

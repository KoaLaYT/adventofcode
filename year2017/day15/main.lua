local h = require('libs.helper')
local s = require('day15.solution')

local start_a = 703
local start_b = 516

h.solve('Part One', function()
  return s.judge_count(start_a, start_b, 40000000)
end)

h.solve('Part Two', function()
  return s.judge_count2(start_a, start_b, 5000000)
end)

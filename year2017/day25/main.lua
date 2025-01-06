local h = require('libs.helper')
local s = require('day25.solution')

local states = {
  ['A'] = s.State:new(1, 1, 'B', 0, -1, 'B'),
  ['B'] = s.State:new(1, -1, 'C', 0, 1, 'E'),
  ['C'] = s.State:new(1, 1, 'E', 0, -1, 'D'),
  ['D'] = s.State:new(1, -1, 'A', 1, -1, 'A'),
  ['E'] = s.State:new(0, 1, 'A', 0, 1, 'F'),
  ['F'] = s.State:new(1, 1, 'E', 1, 1, 'A'),
}

h.solve('Part One', function()
  return s.Machine:new(12683008, states):run()
end)

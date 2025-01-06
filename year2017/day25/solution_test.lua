local test = require('libs.test')
local s = require('day25.solution')

test('Machine:run', function(a)
  local states = {
    ['A'] = s.State:new(1, 1, 'B', 0, -1, 'B'),
    ['B'] = s.State:new(1, -1, 'A', 1, 1, 'A'),
  }
  local m = s.Machine:new(6, states)
  local got = m:run()
  a.equal(got, 3)
end)

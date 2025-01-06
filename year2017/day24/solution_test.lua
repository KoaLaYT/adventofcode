local test = require('libs.test')
local s = require('day24.solution')

test('Component:new', function(a)
  local c = s.Component:new('10/1')
  a.equal(c.a, 10)
  a.equal(c.b, 1)
end)

test('strongest', function(a)
  local input = [[
0/2
2/2
2/3
3/4
3/5
0/1
10/1
9/10]]
  local got = s.strongest(input)
  a.equal(got, 31)
end)

test('longest_strongest', function(a)
  local input = [[
0/2
2/2
2/3
3/4
3/5
0/1
10/1
9/10]]
  local got = s.longest_strongest(input)
  a.equal(got, 19)
end)

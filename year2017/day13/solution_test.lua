local test = require('libs.test')
local s = require('day13.solution')

test('travel', function(a)
  local input = [[
0: 3
1: 2
4: 4
6: 4]]
  local result = s.travel(input)
  a.equal(result, 24)
end)

test('Layer:seek', function(a)
  local test_cases = {
    { 3, 10, 2, -1, },
    { 2, 10, 0, 1, },
    { 4, 10, 2, -1, },
  }
  for _, test_case in ipairs(test_cases) do
    local layer = s.Layer:new(test_case[1])
    layer:seek(test_case[2])
    a.equal(layer.index, test_case[3])
    a.equal(layer.dir, test_case[4])
  end
end)

test('fewest_uncaught', function(a)
  local input = [[
0: 3
1: 2
4: 4
6: 4]]
  local result = s.fewest_uncaught(input)
  a.equal(result, 10)
end)

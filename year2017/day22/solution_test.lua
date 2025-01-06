local test = require('libs.test')
local s = require('day22.solution')

test('Virus:infected_after', function(a)
  local input = [[
..#
#..
...]]
  local test_cases = {
    { 7,     5, },
    { 70,    41, },
    { 10000, 5587, },
  }
  for _, test_case in ipairs(test_cases) do
    local v = s.Virus:new(input)
    local bursts, expect = test_case[1], test_case[2]
    local got = v:infected_after(bursts)
    a.equal(got, expect)
  end
end)

test('Virus:evolved_infected_after', function(a)
  local input = [[
..#
#..
...]]
  local test_cases = {
    { 100,      26, },
    { 10000000, 2511944, },
  }
  for _, test_case in ipairs(test_cases) do
    local v = s.Virus:new(input)
    local bursts, expect = test_case[1], test_case[2]
    local got = v:evolved_infected_after(bursts)
    a.equal(got, expect)
  end
end)

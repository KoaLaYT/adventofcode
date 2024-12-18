local test = require('libs.test')
local s = require('day17.solution')

test('value_after', function(a)
  local test_cases = {
    { 2,    1, },
    { 3,    1, },
    { 4,    3, },
    { 5,    2, },
    { 2017, 638, },
  }
  for _, test_case in ipairs(test_cases) do
    local got = s.value_after(3, test_case[1]);
    a.equal(got, test_case[2]);
  end
end)

test('value_after_zero', function(a)
  local test_cases = {
    { 2, 2, },
    { 3, 2, },
    { 4, 2, },
    { 5, 5, },
    { 9, 9, },
  }
  for _, test_case in ipairs(test_cases) do
    local got = s.value_after_zero(3, test_case[1]);
    a.equal(got, test_case[2]);
  end
end)

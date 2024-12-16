local test = require('libs.test')
local s = require('day14.solution')

test('full_knot_hash', function(a)
  local test_cases = {
    { 'flqrgnkx-0', '11010100', },
    { 'flqrgnkx-1', '01010101', },
    { 'flqrgnkx-2', '00001010', },
  }
  for _, test_case in ipairs(test_cases) do
    local got = s.full_knot_hash(test_case[1])
    a.equal(got:sub(0, 8), test_case[2])
  end
end)

test('used_squares', function(a)
  local got = s.used_squares('flqrgnkx')
  a.equal(got, 8108)
end)

test('count_regions', function(a)
  local got = s.count_regions('flqrgnkx')
  a.equal(got, 1242)
end)

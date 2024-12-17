local test = require('libs.test')
local s = require('day15.solution')

test('judge_count', function(a)
  do
    local got = s.judge_count(65, 8921, 5)
    a.equal(got, 1)
  end

  do
    local got = s.judge_count(65, 8921, 40000000)
    a.equal(got, 588)
  end
end)

test('judge_count2', function(a)
  do
    local got = s.judge_count2(65, 8921, 1056)
    a.equal(got, 1)
  end

  do
    local got = s.judge_count2(65, 8921, 5000000)
    a.equal(got, 309)
  end
end)

local test = require('libs.test')
local s = require('day16.solution')

test('Spin', function(a)
  local test_cases = {
    {
      {
        string.byte('a'),
        string.byte('b'),
        string.byte('c'),
        string.byte('d'),
        string.byte('e'),
      },
      1,
      {
        string.byte('e'),
        string.byte('a'),
        string.byte('b'),
        string.byte('c'),
        string.byte('d'),
      },
    },
    {
      {
        string.byte('a'),
        string.byte('b'),
        string.byte('c'),
        string.byte('d'),
        string.byte('e'),
      },
      3,
      {
        string.byte('c'),
        string.byte('d'),
        string.byte('e'),
        string.byte('a'),
        string.byte('b'),
      },
    },
  }

  for _, test_case in ipairs(test_cases) do
    local spin = s.Spin:new(test_case[2])
    spin:exec(test_case[1], {})

    a.deep_equal(test_case[1], test_case[3])
  end
end)

test('Exchange', function(a)
  local test_cases = {
    {
      {
        string.byte('a'),
        string.byte('b'),
        string.byte('c'),
        string.byte('d'),
        string.byte('e'),
      },
      0, 1,
      {
        string.byte('b'),
        string.byte('a'),
        string.byte('c'),
        string.byte('d'),
        string.byte('e'),
      },
    },
    {
      {
        string.byte('e'),
        string.byte('a'),
        string.byte('b'),
        string.byte('c'),
        string.byte('d'),
      },
      3, 4,
      {
        string.byte('e'),
        string.byte('a'),
        string.byte('b'),
        string.byte('d'),
        string.byte('c'),
      },
    },
  }

  for _, test_case in ipairs(test_cases) do
    local exchange = s.Exchange:new(test_case[2], test_case[3])
    exchange:exec(test_case[1], {})

    a.deep_equal(test_case[1], test_case[4])
  end
end)

test('Partner', function(a)
  local test_cases = {
    {
      {
        string.byte('e'),
        string.byte('a'),
        string.byte('b'),
        string.byte('d'),
        string.byte('c'),
      },
      string.byte('e'), string.byte('b'),
      {
        string.byte('b'),
        string.byte('a'),
        string.byte('e'),
        string.byte('d'),
        string.byte('c'),
      },
    },
    {
      {
        string.byte('a'),
        string.byte('b'),
        string.byte('c'),
        string.byte('d'),
        string.byte('e'),
      },
      string.byte('a'), string.byte('b'),
      {
        string.byte('b'),
        string.byte('a'),
        string.byte('c'),
        string.byte('d'),
        string.byte('e'),
      },
    },
  }

  for _, test_case in ipairs(test_cases) do
    local partner = s.Partner:new(test_case[2], test_case[3])
    partner:exec(test_case[1], {})

    a.deep_equal(test_case[1], test_case[4])
  end
end)

test('dance', function(a)
  local got = s.dance({
    string.byte('a'),
    string.byte('b'),
    string.byte('c'),
    string.byte('d'),
    string.byte('e'),
  }, 's1,x3/4,pe/b')
  a.equal(got, 'baedc')
end)

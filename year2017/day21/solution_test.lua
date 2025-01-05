local test = require('libs.test')
local s = require('day21.solution')

test('Square:from_str', function(a)
  local test_cases = {
    '../.#',
    '.#./..#/###',
    '#..#/..../#..#/.##.',
  }
  for _, test_case in ipairs(test_cases) do
    local square = s.Square:from_str(test_case)
    a.equal(square:concise(), test_case)
  end
end)

test('Square:concise', function(a)
  local test_cases = {
    {
      { { false, false, }, { false, true, }, }, '../.#',
    },
    {
      { { false, true, false, },
        { false, false, true, },
        { true,  true,  true, }, },
      '.#./..#/###',
    },
  }

  for _, test_case in ipairs(test_cases) do
    local grid, expect = test_case[1], test_case[2]
    local square = s.Square:new(grid)
    a.equal(square:concise(), expect)
  end
end)

test('Square:rotate_left', function(a)
  local test_cases = {
    {
      { { false, true, false, },
        { false, false, true, },
        { true,  true,  true, }, },
      '.##/#.#/..#',
    },
  }

  for _, test_case in ipairs(test_cases) do
    local grid, expect = test_case[1], test_case[2]
    local square = s.Square:new(grid)
    a.equal(square:rotate_left():concise(), expect)
  end
end)

test('Square:rotate_right', function(a)
  local test_cases = {
    {
      { { false, true, false, },
        { false, false, true, },
        { true,  true,  true, }, },
      '#../#.#/##.',
    },
  }

  for _, test_case in ipairs(test_cases) do
    local grid, expect = test_case[1], test_case[2]
    local square = s.Square:new(grid)
    a.equal(square:rotate_right():concise(), expect)
  end
end)

test('Square:flip_y', function(a)
  local test_cases = {
    {
      { { false, true, false, },
        { false, false, true, },
        { true,  true,  true, }, },
      '.#./#../###',
    },
  }

  for _, test_case in ipairs(test_cases) do
    local grid, expect = test_case[1], test_case[2]
    local square = s.Square:new(grid)
    a.equal(square:flip_y():concise(), expect)
  end
end)

test('Square:flip_x', function(a)
  local test_cases = {
    {
      { { false, true, false, },
        { false, false, true, },
        { true,  true,  true, }, },
      '###/..#/.#.',
    },
  }

  for _, test_case in ipairs(test_cases) do
    local grid, expect = test_case[1], test_case[2]
    local square = s.Square:new(grid)
    a.equal(square:flip_x():concise(), expect)
  end
end)

test('Square:expand', function(a)
  local rules = {
    ['#./..'] = '##./#../...',
    ['.#/..'] = '##./#../...',
    ['../#.'] = '##./#../...',
    ['../.#'] = '##./#../...',
    ['.#./..#/###'] = '#..#/..../..../#..#',
  }
  local test_cases = {
    {
      '.#./..#/###',
      '#..#/..../..../#..#',
    },
    {
      '#..#/..../..../#..#',
      '##.##./#..#../....../##.##./#..#../......',
    },
  }

  for _, test_case in ipairs(test_cases) do
    local square = s.Square:from_str(test_case[1])
    local got = square:expand(rules)
    a.equal(got:concise(), test_case[2])
  end
end)

test('build_rules', function(a)
  local input = [[
../.# => ##./#../...
.#./..#/### => #..#/..../..../#..#]]
  local got = s.build_rules(input)
  local size = 0
  for _ in pairs(got) do
    size = size + 1
  end
  a.equal(size, 12)
end)

test('expand', function(a)
  local input = [[
../.# => ##./#../...
.#./..#/### => #..#/..../..../#..#]]
  local got = s.expand(input, 2)
  a.equal(got, 12)
end)

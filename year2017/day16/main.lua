local h = require('libs.helper')
local s = require('day16.solution')

local input = h.getinput()

h.solve('Part One', function()
  local arr = {
    string.byte('a'),
    string.byte('b'),
    string.byte('c'),
    string.byte('d'),
    string.byte('e'),
    string.byte('f'),
    string.byte('g'),
    string.byte('h'),
    string.byte('i'),
    string.byte('j'),
    string.byte('k'),
    string.byte('l'),
    string.byte('m'),
    string.byte('n'),
    string.byte('o'),
    string.byte('p'),
  }
  return s.dance(arr, input)
end)

h.solve('Part One', function()
  local arr = {
    string.byte('a'),
    string.byte('b'),
    string.byte('c'),
    string.byte('d'),
    string.byte('e'),
    string.byte('f'),
    string.byte('g'),
    string.byte('h'),
    string.byte('i'),
    string.byte('j'),
    string.byte('k'),
    string.byte('l'),
    string.byte('m'),
    string.byte('n'),
    string.byte('o'),
    string.byte('p'),
  }
  return s.dance2(arr, input, 1000000000)
end)

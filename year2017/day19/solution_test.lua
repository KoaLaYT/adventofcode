local test = require('libs.test')
local s = require('day19.solution')

test('Route:letters', function(a)
  local input = [[
     |
     |  +--+
     A  |  C
 F---|----E|--+
     |  |  |  D
     +B-+  +--+]]

  local got = s.Route:new(input):letters()
  a.equal(got, 'ABCDEF')
end)

test('Route:steps', function(a)
  local input = [[
     |
     |  +--+
     A  |  C
 F---|----E|--+
     |  |  |  D
     +B-+  +--+]]

  local got = s.Route:new(input):steps()
  a.equal(got, 38)
end)

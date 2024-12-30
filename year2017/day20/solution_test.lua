local test = require('libs.test')
local s = require('day20.solution')

test('Particle:new', function(a)
  local input = 'p=<-1261,-2279,-480>, v=<-13,82,66>, a=<14,11,-4>'
  local got = s.Particle:new(input)
  a.equal(got.p.x, -1261)
  a.equal(got.p.y, -2279)
  a.equal(got.p.z, -480)

  a.equal(got.v.x, -13)
  a.equal(got.v.y, 82)
  a.equal(got.v.z, 66)

  a.equal(got.a.x, 14)
  a.equal(got.a.y, 11)
  a.equal(got.a.z, -4)
end)

test('closest', function(a)
  local input = [[
p=< 4,0,0>, v=< 0,0,0>, a=<-2,0,0>
p=< 3,0,0>, v=< 2,0,0>, a=<-1,0,0>]]

  local got = s.closest(input)
  a.equal(got, 1)
end
)

test('left', function(a)
  local input = [[
p=<-6,0,0>, v=< 3,0,0>, a=< 0,0,0>
p=<-4,0,0>, v=< 2,0,0>, a=< 0,0,0>
p=<-2,0,0>, v=< 1,0,0>, a=< 0,0,0>
p=< 3,0,0>, v=<-1,0,0>, a=< 0,0,0>]]

  local got = s.left(input)
  a.equal(got, 1)
end
)

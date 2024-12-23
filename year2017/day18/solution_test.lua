local test = require('libs.test')
local s = require('day18.solution')

test('Tablet', function(a)
  local input = [[
set a 1
add a 2
mul a a
mod a 5
snd a
set a 0
rcv a
jgz a -1
set a 1
jgz a -2]]

  local tablet = s.Tablet:new(input)
  local got = tablet:first_rcv_nonzero()
  a.equal(got, 4)
end)

test('run_two_tablets', function(a)
  local input = [[
snd 1
snd 2
snd p
rcv a
rcv b
rcv c
rcv d]]

  local got = s.run_two_tablets(input)
  a.equal(got, 3)
end)

local test = require('libs.test')
local s = require('day23.solution')

test('Processor', function(a)
  local input = [[
sub b -100000
set c b
sub c -17000]]
  s.Processor:new(input)
end)

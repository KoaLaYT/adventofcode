local test = require('libs.test')
local s = require('day14.solution')

test('Generator:index', function(a)
    local g = s.Generator:new('abc')
    local got = g:index(64)
    a.equal(got, 22728)
end)

test('Generator:index_v2', function(a)
    local g = s.Generator:new('abc')
    local got = g:index_v2(1)
    a.equal(got, 10)
end)

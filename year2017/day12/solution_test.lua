local test = require('libs.test')
local s = require('day12.solution')

test('parse', function(a)
    local input = [[
0 <-> 2
1 <-> 1
2 <-> 0, 3, 4
3 <-> 2, 4
4 <-> 2, 3, 6
5 <-> 6
6 <-> 4, 5]]

    local map, max_id = s.parse(input)
    a.equal(max_id, 6)
    a.deep_equal(map[4], { 2, 3, 6, })
    a.deep_equal(map[5], { 6, })
    a.deep_equal(map[6], { 4, 5, })
end)

test('contact_zero_programs', function(a)
    local input = [[
0 <-> 2
1 <-> 1
2 <-> 0, 3, 4
3 <-> 2, 4
4 <-> 2, 3, 6
5 <-> 6
6 <-> 4, 5]]

    local got = s.contact_zero_programs(input)
    a.equal(got, 6)
end)

test('groups', function(a)
    local input = [[
0 <-> 2
1 <-> 1
2 <-> 0, 3, 4
3 <-> 2, 4
4 <-> 2, 3, 6
5 <-> 6
6 <-> 4, 5]]

    local got = s.groups(input)
    a.equal(got, 2)
end)

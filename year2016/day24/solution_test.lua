local test = require('libs.test')
local s = require('day24.solution')

test('_shortest_route', function(a)
    local routes = {
        ['0-1'] = 2,
        ['0-2'] = 8,
        ['0-3'] = 10,
        ['0-4'] = 2,
        ['1-0'] = 2,
        ['1-2'] = 6,
        ['1-3'] = 8,
        ['1-4'] = 4,
        ['2-0'] = 8,
        ['2-1'] = 6,
        ['2-3'] = 2,
        ['2-4'] = 10,
        ['3-0'] = 10,
        ['3-1'] = 8,
        ['3-2'] = 2,
        ['3-4'] = 8,
        ['4-0'] = 2,
        ['4-1'] = 4,
        ['4-2'] = 10,
        ['4-3'] = 8,
    }

    do
        local got = s._shortest_route(routes, 4)
        a.equal(got, 14)
    end

    do
        local got = s._shortest_route_v2(routes, 4)
        a.equal(got, 20)
    end
end)

test('shortest_route', function(a)
    local input = [[
###########
#0.1.....2#
#.#######.#
#4.......3#
###########]]

    local got = s.shortest_route(input)
    a.equal(got, 14)
end)

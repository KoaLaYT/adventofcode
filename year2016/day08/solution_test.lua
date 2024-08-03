local test = require('libs.test')
local s = require('day08.solution')

test('Screen:__tostring', function(a)
    local screen = s.Screen:new(6, 50)
    local expect = [[
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
]]
    a.equal(tostring(screen), expect)
end)

test('Screen operations', function(a)
    local ops = {
        {
            input = s.RectOp:new(3, 2),
            expect =
            [[
###....
###....
.......
]],
        },
        {
            input = s.RotateColOp:new(2, 1),
            expect = [[
#.#....
###....
.#.....
]],
        },
        {
            input = s.RotateRowOp:new(1, 4),
            expect = [[
....#.#
###....
.#.....
]],
        },
        {
            input = s.RotateColOp:new(2, 1),
            expect = [[
.#..#.#
#.#....
.#.....
]],
        },
    }

    local screen = s.Screen:new(3, 7)
    for _, tt in ipairs(ops) do
        tt.input:update(screen)
        a.equal(tostring(screen), tt.expect)
    end
end)

test('parse_op', function(a)
    local testcases = {
        {
            input = 'rect 34x12',
            expect = s.RectOp:new(34, 12),
        },
        {
            input = 'rotate row y=0 by 10',
            expect = s.RotateRowOp:new(1, 10),
        },
        {
            input = 'rotate column x=7 by 35',
            expect = s.RotateColOp:new(8, 35),
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.parse_op(tt.input)
        a.deep_equal(got, tt.expect)
    end
end)

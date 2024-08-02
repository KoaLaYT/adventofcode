local test = require('libs.test')
local s = require('day01.solution')

test('parse instruction', function(a)
    local testcases = {
        {
            input = 'R2, L3',
            expect = { { turn = 1, blocks = 2, }, { turn = -1, blocks = 3, }, },
        },
        {
            input = 'R2, R2, R2',
            expect = {
                { turn = 1, blocks = 2, },
                { turn = 1, blocks = 2, },
                { turn = 1, blocks = 2, },
            },
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.parse_instructions(tt.input)
        a.deep_equal(got, tt.expect)
    end
end)

test('human walks', function(a)
    local testcases = {
        {
            input = 'R2, L3',
            expect = 5,
        },
        {
            input = 'R2, R2, R2',
            expect = 2,
        },
        {
            input = 'R2, R2, R2, R2',
            expect = 0,
        },
        {
            input = 'R5, L5, R5, R3',
            expect = 12,
        },
    }

    for _, tt in ipairs(testcases) do
        local h = s.Human:new()
        h:walks(s.parse_instructions(tt.input))
        local got = h:distance()
        a.equal(got, tt.expect)
    end
end)

test('find first location visit twice', function(a)
    local testcases = {
        {
            input = 'R8, R4, R4, R8',
            expect = 4,
        },
        {
            input = 'R2, L3',
            expect = 5,
        },
        {
            input = 'R2, R2, R2, R2',
            expect = 0,
        },
        {
            input = 'R2, L2, L1, L100',
            expect = 1,
        },
    }

    for _, tt in ipairs(testcases) do
        local h = s.Human:new()
        local instructions = s.parse_instructions(tt.input)
        h:walks(instructions, { ['0,0'] = 1, })
        local got = h:distance()
        a.equal(got, tt.expect)
    end
end)

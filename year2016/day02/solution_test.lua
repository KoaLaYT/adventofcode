local test = require('libs.test')
local s = require('day02.solution')

test('Keypad:_get_one_code', function(a)
    local testcases = {
        {
            input = 'ULL',
            expect = '1',
        },
        {
            input = 'RRDDD',
            expect = '9',
        },
        {
            input = 'LURDL',
            expect = '8',
        },
        {
            input = 'UUUUD',
            expect = '5',
        },
    }

    local keypad = s.Keypad:new()
    for _, tt in ipairs(testcases) do
        ---@diagnostic disable-next-line: invisible
        local got = keypad:_get_one_code(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('Keypad:get_code', function(a)
    local keypad = s.Keypad:new()
    local got = keypad:get_code([[ULL
RRDDD
LURDL
UUUUD]])
    a.equal(got, '1985')
end)

test('BathroomKeypad:_get_one_code', function(a)
    local testcases = {
        {
            input = 'ULL',
            expect = '5',
        },
        {
            input = 'RRDDD',
            expect = 'D',
        },
        {
            input = 'LURDL',
            expect = 'B',
        },
        {
            input = 'UUUUD',
            expect = '3',
        },
    }

    local keypad = s.BathroomKeypad:new()
    for _, tt in ipairs(testcases) do
        ---@diagnostic disable-next-line: invisible
        local got = keypad:_get_one_code(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('BathroomKeypad:get_code', function(a)
    local keypad = s.BathroomKeypad:new()
    local got = keypad:get_code([[ULL
RRDDD
LURDL
UUUUD]])
    a.equal(got, '5DB3')
end)

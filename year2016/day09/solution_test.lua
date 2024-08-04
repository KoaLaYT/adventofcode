local test = require('libs.test')
local s = require('day09.solution')

test('decompressed_length', function(a)
    local testcases = {
        {
            input = 'ADVENT',
            expect = 6,
        },
        {
            input = 'A(1x5)BC',
            expect = 7,
        },
        {
            input = '(3x3)XYZ',
            expect = 9,
        },
        {
            input = 'A(2x2)BCD(2x2)EFG',
            expect = 11,
        },
        {
            input = '(6x1)(1x3)A',
            expect = 6,
        },
        {
            input = 'X(8x2)(3x3)ABCY',
            expect = 18,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.decompressed_length(tt.input)
        a.equal(got, tt.expect,
            string.format('%s, got: %d, expect %d', tt.input, got, tt.expect))
    end
end)

test('decompressed_length_v2', function(a)
    local testcases = {
        {
            input = '(3x3)XYZ',
            expect = 9,
        },
        {
            input = 'X(8x2)(3x3)ABCY',
            expect = 20,
        },
        {
            input = '(27x12)(20x12)(13x14)(7x10)(1x12)A',
            expect = 241920,
        },
        {
            input = '(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN',
            expect = 445,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.decompressed_length_v2(tt.input)
        a.equal(got, tt.expect,
            string.format('%s, got: %d, expect %d', tt.input, got, tt.expect))
    end
end)

local test = require('libs.test')
local s = require('day06.solution')

test('_most_frequent', function(a)
    local testcases = {
        {
            input = { [0] = 1, [1] = 0, [2] = 2, },
            expect = 2,
        },
        {
            input = { [0] = 3, [1] = 0, [2] = 2, },
            expect = 0,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s._most_frequent(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('correct_error', function(a)
    local input = [[
eedadn
drvtee
eandsr
raavrd
atevrs
tsrnev
sdttsa
rasrtv
nssdts
ntnada
svetve
tesnvt
vntsnd
vrdear
dvrsen
enarar
]]
    do
        local expect = 'easter'
        local got = s.correct_error(input)
        a.equal(got, expect)
    end

    do
        local expect = 'advent'
        local got = s.correct_error_v2(input)
        a.equal(got, expect)
    end
end)

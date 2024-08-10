local test = require('libs.test')
local s = require('day02.solution')

test('parse', function(a)
    local input = '737	1866	1565	1452	1908	1874	232	1928	201	241	922	281	1651	1740	1012	1001'
    local expect = { 737, 1866, 1565, 1452, 1908,
        1874, 232, 1928, 201, 241,
        922, 281, 1651, 1740, 1012, 1001, }
    local got = s.parse(input)
    a.equal(#got, #expect)
    for i = 1, #expect do
        a.equal(got[i], expect[i])
    end
end)

test('differences', function(a)
    local testcases = {
        { input = '5 1 9 5', expect = 8, },
        { input = '7 5 3',   expect = 4, },
        { input = '2 4 6 8', expect = 6, },
    }

    for _, tt in ipairs(testcases) do
        local got = s.differences(s.parse(tt.input))
        a.equal(got, tt.expect)
    end
end)

test('division', function(a)
    local testcases = {
        { input = '5 9 2 8', expect = 4, },
        { input = '9 4 7 3', expect = 3, },
        { input = '3 8 6 5', expect = 2, },
    }

    for _, tt in ipairs(testcases) do
        local got = s.division(s.parse(tt.input))
        a.equal(got, tt.expect)
    end
end)

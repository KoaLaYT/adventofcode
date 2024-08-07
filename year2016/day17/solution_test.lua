local test = require('libs.test')
local s = require('day17.solution')

test('shortest_path', function(a)
    local testcases = {
        { input = 'ihgpwlah', expect = 'DDRRRD', },
        { input = 'kglvqrro', expect = 'DDUDRLRRUDRD', },
        { input = 'ulqzkmiv', expect = 'DRURDRUDDLLDLUURRDULRLDUUDDDRR', },
    }

    for _, tt in ipairs(testcases) do
        local got = s.shortest_path(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('longest_path', function(a)
    local testcases = {
        { input = 'ihgpwlah', expect = 370, },
        { input = 'kglvqrro', expect = 492, },
        { input = 'ulqzkmiv', expect = 830, },
    }

    for _, tt in ipairs(testcases) do
        local got = s.longest_path(tt.input)
        a.equal(got, tt.expect)
    end
end)

local test = require('libs.test')
local s = require('day07.solution')

test('parse', function(a)
    local testcases = {
        {
            input = 'pbga (66)',
            expect = { 'pbga', 66, {}, },
        },
        {
            input = 'pbga (66) -> ktlj, cntj, xhth',
            expect = { 'pbga', 66, { 'ktlj', 'cntj', 'xhth', }, },
        },
    }

    for _, tt in ipairs(testcases) do
        local name, weight, aboves = s.parse(tt.input)
        a.equal(name, tt.expect[1])
        a.equal(weight, tt.expect[2])
        a.deep_equal(aboves, tt.expect[3])
    end
end)

test('find_bottom', function(a)
    local input = [[
pbga (66)
xhth (57)
ebii (61)
havc (66)
ktlj (57)
fwft (72) -> ktlj, cntj, xhth
qoyq (66)
padx (45) -> pbga, havc, qoyq
tknk (41) -> ugml, padx, fwft
jptl (61)
ugml (68) -> gyxo, ebii, jptl
gyxo (61)
cntj (57)]]
    local got = s.find_bottom(input)
    a.equal(got, 'tknk')
end)

test('find_inbalance', function(a)
    local input = [[
pbga (66)
xhth (57)
ebii (61)
havc (66)
ktlj (57)
fwft (72) -> ktlj, cntj, xhth
qoyq (66)
padx (45) -> pbga, havc, qoyq
tknk (41) -> ugml, padx, fwft
jptl (61)
ugml (68) -> gyxo, ebii, jptl
gyxo (61)
cntj (57)]]
    local got = s.find_inbalance(input)
    a.equal(got, 60)
end)

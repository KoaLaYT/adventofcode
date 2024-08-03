local test = require('libs.test')
local s = require('day07.solution')

test('_hasABBA', function(a)
    local testcases = {
        {
            input = 'abba',
            expect = true,
        },
        {
            input = 'ioxxoj',
            expect = true,
        },
        {
            input = 'abcd',
            expect = false,
        },
        {
            input = 'aaaa',
            expect = false,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s._hasABBA(tt.input)
        a.equal(got, tt.expect, string.format('%s, got %s, expect %s',
            tt.input, tostring(got), tostring(tt.expect)))
    end
end)

test('_iter_ipv7', function(a)
    local testcases = {
        {
            input = 'abba[mnop]qrst',
            expect = {
                { in_bracket = false, str = 'abba', },
                { in_bracket = true,  str = 'mnop', },
                { in_bracket = false, str = 'qrst', },
            },
        },
        {
            input = 'abc[a]b[acba]abccddc',
            expect = {
                { in_bracket = false, str = 'abc', },
                { in_bracket = true,  str = 'a', },
                { in_bracket = false, str = 'b', },
                { in_bracket = true,  str = 'acba', },
                { in_bracket = false, str = 'abccddc', },
            },
        },
    }

    for _, tt in ipairs(testcases) do
        local got = {}
        for _, subnet in s._iter_ipv7, tt.input, 1 do
            table.insert(got, subnet)
        end
        a.deep_equal(got, tt.expect)
    end
end)

test('support_tls', function(a)
    local testcases = {
        {
            input = 'abba[mnop]qrst',
            expect = true,
        },
        {
            input = 'abcd[bddb]xyyx',
            expect = false,
        },
        {
            input = 'aaaa[qwer]tyui',
            expect = false,
        },
        {
            input = 'ioxxoj[asdfgh]zxcvbn',
            expect = true,
        },
        {
            input = 'abc[a]b[abba]ccdd',
            expect = false,
        },
        {
            input = 'abc[a]b[acba]abccddc',
            expect = true,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.support_tls(tt.input)
        a.equal(got, tt.expect, string.format('%s, got %s, expect %s',
            tt.input, tostring(got), tostring(tt.expect)))
    end
end)

test('support_ssl', function(a)
    local testcases = {
        {
            input = 'aba[bab]xyz',
            expect = true,
        },
        {
            input = 'xyx[xyx]xyx',
            expect = false,
        },
        {
            input = 'aaa[kek]eke',
            expect = true,
        },
        {
            input = 'zazbz[bzb]cdb',
            expect = true,
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s.support_ssl(tt.input)
        a.equal(got, tt.expect)
    end
end)

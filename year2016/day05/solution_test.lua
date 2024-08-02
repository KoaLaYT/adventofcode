local test = require('libs.test')
local s = require('day05.solution')

test('_md5_openssl', function(a)
    local testcases = {
        {
            input = 'The quick brown fox jumps over the lazy dog',
            expect = '9e107d9d372bb6826bd81d3542a419d6',
        },
        {
            input = 'The quick brown fox jumps over the lazy dog.',
            expect = 'e4d909c290d0fb1ca068ffaddf22cbd0',
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s._md5_openssl(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('_md5', function(a)
    local testcases = {
        {
            input = 'The quick brown fox jumps over the lazy dog',
            expect = '9e107d9d372bb6826bd81d3542a419d6',
        },
        {
            input = 'The quick brown fox jumps over the lazy dog.',
            expect = 'e4d909c290d0fb1ca068ffaddf22cbd0',
        },
    }

    for _, tt in ipairs(testcases) do
        local got = s._md5(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('_find_one_password', function(a)
    local testcases = {
        {
            input = { 'abc', 3200000, '00000', },
            expect = { 3231929 + 1, '1', },
        },
        {
            input = { 'abc', 5010000, '00000', },
            expect = { 5017308 + 1, '8', },
        },
    }

    for _, tt in ipairs(testcases) do
        local next, one_passwd = s._find_one_password(
            tt.input[1], tt.input[2], tt.input[3])
        a.equal(next, tt.expect[1])
        a.equal(one_passwd, tt.expect[2])
    end
end)

test('find_password', function(a)
    local expect = '18f47a30'
    local find_one_fun = function()
        local i = 1
        return function()
            local one = expect:sub(i, i)
            i = i + 1
            return i, one
        end
    end
    local got = s.find_password('abc', '00000', find_one_fun())
    a.equal(got, expect)
end)

test('find_password_v2', function(a)
    local expect = '05ace8e3'
    local find_one_fun = function()
        local i = 1
        return function()
            local two = (i - 1) .. expect:sub(i, i)
            i = i + 1
            return i, two
        end
    end
    local got = s.find_password_v2('abc', '00000', find_one_fun())
    a.equal(got, expect)
end)

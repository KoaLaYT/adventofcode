local test = require('libs.test')
local s = require('day16.solution')

test('_modified_dragon_curve', function(a)
    local testcases = {
        { input = '1',            expect = '100', },
        { input = '0',            expect = '001', },
        { input = '11111',        expect = '11111000000', },
        { input = '111100001010', expect = '1111000010100101011110000', },
    }

    for _, tt in ipairs(testcases) do
        local got = s._modified_dragon_curve(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('_checksum', function(a)
    local testcases = {
        { input = '110010110100', expect = '100', },
    }

    for _, tt in ipairs(testcases) do
        local got = s._checksum(tt.input)
        a.equal(got, tt.expect)
    end
end)

test('full_disk', function(a)
    local testcases = {
        { input = { '10000', 20, }, expect = '01100', },
    }

    for _, tt in ipairs(testcases) do
        local got = s.full_disk(unpack(tt.input))
        a.equal(got, tt.expect)
    end
end)

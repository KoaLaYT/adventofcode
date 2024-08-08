local test = require('libs.test')
local s = require('day21.solution')

---@param s string
---@return integer[]
local function string_to_bytes(s)
    local bytes = {}
    for i = 1, #s do
        bytes[i] = s:byte(i)
    end
    return bytes
end

test('_rotate_left', function(a)
    local testcases = {
        { input = { 'abcd', 1, }, expect = 'bcda', },
        { input = { 'abcd', 2, }, expect = 'cdab', },
        { input = { 'abcd', 3, }, expect = 'dabc', },
        { input = { 'abcd', 4, }, expect = 'abcd', },
        { input = { 'abcd', 5, }, expect = 'bcda', },
    }

    for _, tt in ipairs(testcases) do
        local bytes = string_to_bytes(tt.input[1])
        s._rotate_left(bytes, {}, tt.input[2])
        a.equal(string.char(unpack(bytes)), tt.expect)
    end
end)

test('_rotate_right', function(a)
    local testcases = {
        { input = { 'abcd', 1, }, expect = 'dabc', },
        { input = { 'abcd', 2, }, expect = 'cdab', },
        { input = { 'abcd', 3, }, expect = 'bcda', },
        { input = { 'abcd', 4, }, expect = 'abcd', },
        { input = { 'abcd', 5, }, expect = 'dabc', },
    }

    for _, tt in ipairs(testcases) do
        local bytes = string_to_bytes(tt.input[1])
        s._rotate_right(bytes, {}, tt.input[2])
        a.equal(string.char(unpack(bytes)), tt.expect)
    end
end)

test('_move_position', function(a)
    local testcases = {
        { input = { 'bcdea', 2, 5, }, expect = 'bdeac', },
        { input = { 'bcdea', 2, 1, }, expect = 'cbdea', },
    }

    for _, tt in ipairs(testcases) do
        local bytes = string_to_bytes(tt.input[1])
        s._move_position(bytes, {}, tt.input[2], tt.input[3])
        a.equal(string.char(unpack(bytes)), tt.expect)
    end
end)

test('scramble_password', function(a)
    local input = [[
swap position 4 with position 0
swap letter d with letter b
reverse positions 0 through 4
rotate left 1 step
move position 1 to position 4
move position 3 to position 0
rotate based on position of letter b
rotate based on position of letter d
]]
    local got = s.scramble_password('abcde', input)
    a.equal(got, 'decab')
end)

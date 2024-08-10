local ffi = require('ffi')
ffi.cdef([[
int is_valid(const char* passphrase, int len);
int is_valid_v2(const char* passphrase, int len);
]])

local clib = ffi.load('solution')

---@param s string
---@return boolean
local function is_valid(s)
    return clib.is_valid(s, #s) == 1
end

---@param s string
---@return boolean
local function is_valid_v2(s)
    return clib.is_valid_v2(s, #s) == 1
end

---@param input string
---@param part2 boolean?
---@return integer
local function count_valid_passphrases(input, part2)
    local count = 0
    for line in input:gmatch('[^\r\n]+') do
        if part2 and is_valid_v2(line) then
            count = count + 1
        elseif not part2 and is_valid(line) then
            count = count + 1
        end
    end
    return count
end

local M = {}
M.is_valid = is_valid
M.is_valid_v2 = is_valid_v2
M.count_valid_passphrases = count_valid_passphrases
return M

local md5 = require('libs.md5')
local openssl_md5, err = require('resty.openssl.digest').new('md5')
if err ~= nil then error(err) end

---@param buf string
---@param string
local function _hex_dump(buf)
    return buf:gsub('.', function(c)
        return string.format('%02x', string.byte(c))
    end)
end

---@param input string
---@param string
local function _md5_openssl(input)
    assert(openssl_md5:reset())
    openssl_md5:update(input)
    local digest = openssl_md5:final()
    return _hex_dump(digest)
end

---@param input string
---@return string
local function _md5(input)
    return md5.sumhexa(input)
end

---@param prefix string
---@param start integer
---@param pattern string
---@return integer, string # one character of password
local function _find_one_password(prefix, start, pattern)
    while true do
        local input = string.format('%s%d', prefix, start)
        local hash = _md5_openssl(input)
        start = start + 1
        if hash:sub(1, #pattern) == pattern then
            return start, hash:sub(#pattern + 1, #pattern + 1)
        end
    end
end
---
---@param prefix string
---@param start integer
---@param pattern string
---@return integer next, string # position and one character of password
local function _find_one_password_v2(prefix, start, pattern)
    while true do
        local input = string.format('%s%d', prefix, start)
        local hash = _md5_openssl(input)
        start = start + 1
        if hash:sub(1, #pattern) == pattern then
            return start, hash:sub(#pattern + 1, #pattern + 2)
        end
    end
end

---@param prefix string
---@param pattern string
local function find_password(prefix, pattern, find_one_fun)
    local result = ''
    local idx = 0
    -- for quick test
    find_one_fun = find_one_fun or _find_one_password

    while #result < 8 do
        local next, one_passwd = find_one_fun(prefix, idx, pattern)
        result = result .. one_passwd
        idx = next
    end

    return result
end

local zero = string.byte('0')

---@param prefix string
---@param pattern string
local function find_password_v2(prefix, pattern, find_one_fun)
    local result = {}
    local idx = 0
    local found = 0
    find_one_fun = find_one_fun or _find_one_password_v2

    while found < 8 do
        local next, one_passwd = find_one_fun(prefix, idx, pattern)
        local pos = one_passwd:byte(1) - zero
        if pos >= 0 and pos <= 7 and result[pos + 1] == nil then
            result[pos + 1] = one_passwd:byte(2)
            found = found + 1
        end
        idx = next
    end

    local password = ''
    for _, char in ipairs(result) do
        password = password .. string.char(char)
    end
    return password
end

local M = {}
M._md5 = _md5
M._md5_openssl = _md5_openssl
M._find_one_password = _find_one_password
M.find_password = find_password
M.find_password_v2 = find_password_v2
return M

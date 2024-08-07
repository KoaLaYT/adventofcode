local one = string.byte('1')
local zero = string.byte('0')

---@param s string
---@return string
local function _modified_dragon_curve(s)
    local copy = {}
    for i = #s, 1, -1 do
        local b = s:byte(i)
        if b == one then
            copy[#s - i + 1] = '0'
        else
            copy[#s - i + 1] = '1'
        end
    end
    return s .. '0' .. table.concat(copy)
end

---@param s string
---@return string
local function _checksum(s)
    if #s < 2 then return s end

    local result = {}
    for i = 1, #s do
        result[i] = s:byte(i) == zero and '0' or '1'
    end

    local len = #result
    while len % 2 == 0 do
        for k = 1, len / 2 do
            if result[k * 2 - 1] == result[k * 2] then
                result[k] = '1'
            else
                result[k] = '0'
            end
            k = k + 1
        end
        len = len / 2
    end
    return table.concat(result, '', 1, len)
end

---@param s string
---@param len integer
---@return string
local function full_disk(s, len)
    while #s < len do
        s = _modified_dragon_curve(s)
    end
    s = s:sub(1, len)
    return _checksum(s)
end

local M = {}
M._modified_dragon_curve = _modified_dragon_curve
M._checksum = _checksum
M.full_disk = full_disk
return M

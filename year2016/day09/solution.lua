local left_parentheses = string.byte('(')
local right_parentheses = string.byte(')')
local x = string.byte('x')

---@param str string
---@param from integer
---@param to integer
---@return integer
local function _decompressed_length_v2(str, from, to)
    local len = 0

    local i = from
    while i <= to do
        local b = str:byte(i)
        if b ~= left_parentheses then
            len = len + 1
            i = i + 1
        else
            local j = i + 1
            while str:byte(j) ~= x do
                j = j + 1
            end
            local size = assert(tonumber(str:sub(i + 1, j - 1)))
            local k = j + 1
            while str:byte(k) ~= right_parentheses do
                k = k + 1
            end
            local rep = assert(tonumber(str:sub(j + 1, k - 1)))
            len = len + rep * _decompressed_length_v2(str, k + 1, k + size)
            i = k + 1 + size
        end
    end

    return len
end

---@param str string
---@return integer
local function decompressed_length_v2(str)
    return _decompressed_length_v2(str, 1, #str)
end

---@param str string
---@return integer
local function decompressed_length(str)
    local len = 0

    local i = 1
    while i <= #str do
        local b = str:byte(i)
        if b ~= left_parentheses then
            len = len + 1
            i = i + 1
        else
            local j = i + 1
            while str:byte(j) ~= x do
                j = j + 1
            end
            local size = assert(tonumber(str:sub(i + 1, j - 1)))
            local k = j + 1
            while str:byte(k) ~= right_parentheses do
                k = k + 1
            end
            local rep = assert(tonumber(str:sub(j + 1, k - 1)))
            len = len + size * rep
            i = k + 1 + size
        end
    end

    return len
end

local M = {}
M.decompressed_length = decompressed_length
M.decompressed_length_v2 = decompressed_length_v2
return M

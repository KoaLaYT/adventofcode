---@param count table<integer, integer>
---@return integer
local function _most_frequent(count)
    local most_k, most_v = 0, 0
    for k, v in pairs(count) do
        if v > most_v then
            most_k = k
            most_v = v
        end
    end
    return most_k
end
---
---@param count table<integer, integer>
---@return integer
local function _least_frequent(count)
    local least_k, least_v = 0, math.huge
    for k, v in pairs(count) do
        if v < least_v then
            least_k = k
            least_v = v
        end
    end
    return least_k
end

---@param input string
---@return table<integer, integer>[]
local function _count_input(input)
    local count = {}
    for line in input:gmatch('[^\r\n]+') do
        for i = 1, #line do
            local b = line:byte(i)
            if count[i] == nil then count[i] = {} end
            if count[i][b] == nil then count[i][b] = 0 end
            count[i][b] = count[i][b] + 1
        end
    end
    return count
end

---@param input string
---@return string
local function correct_error(input)
    local count = _count_input(input)
    local result = {}
    for _, c in ipairs(count) do
        table.insert(result, #result + 1, _most_frequent(c))
    end

    return string.char(unpack(result))
end

---@param input string
---@return string
local function correct_error_v2(input)
    local count = _count_input(input)
    local result = {}
    for _, c in ipairs(count) do
        table.insert(result, #result + 1, _least_frequent(c))
    end

    return string.char(unpack(result))
end

local M            = {}
M._most_frequent   = _most_frequent
M.correct_error    = correct_error
M.correct_error_v2 = correct_error_v2
return M

local M = {}

---Get current time in ms
---@return number?
local function gethammertime()
    return tonumber(assert(assert(io.popen('date +%s%3N')):read('a')))
end

---@param start_ms number?
---@param end_ms number?
---@return string
local function time_diff_str(start_ms, end_ms)
    local diff = end_ms - start_ms
    if diff < 1000 then
        return diff .. 'ms'
    else
        return diff / 1000 .. 's'
    end
end

---@param label string
---@param solution fun(): any
M.solve = function(label, solution)
    print('>>>> ' .. label .. ' <<<<')

    local start_ms = gethammertime()
    local result = solution()
    local end_ms = gethammertime()
    print('Answer: ' .. result)
    print('Took: ' .. time_diff_str(start_ms, end_ms))
end

---@return string
M.getinput = function()
    local inputfile = arg[1]
    if inputfile == nil then
        inputfile = string.gsub(arg[0], 'main.lua', 'input.txt')
    end

    local f = assert(io.open(inputfile, 'r'))
    local t = f:read('*a')
    assert(f:close())
    return t
end

---@param s string
---@param i integer
---@return integer, integer
M.parse_integer = function(s, i)
    local result = 0
    local byte_0 = string.byte('0')
    local byte_9 = string.byte('9')
    while i <= #s do
        local c = string.byte(s:sub(i, i))
        if c < byte_0 or c > byte_9 then
            break
        end
        result = 10 * result + c - byte_0
        i = i + 1
    end
    return result, i
end

return M

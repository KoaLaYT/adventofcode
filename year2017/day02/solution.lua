local ffi = require('ffi')
ffi.cdef([[
int differences(const int* row, int len);
int division(const int* row, int len);
]])
local clib = ffi.load('solution')

---@param row integer[]
---@return integer
local function differences(row)
    local v = ffi.new('int[?]', #row, row)
    return clib.differences(v, #row)
end

---@param row integer[]
---@return integer
local function division(row)
    local v = ffi.new('int[?]', #row, row)
    local r = clib.division(v, #row)
    if r <= 0 then error('bad division') end
    return r
end

---@param input string
---@return integer[]
local function parse(input)
    local row = {}
    for num in input:gmatch('[^ \t]+') do
        row[#row + 1] = assert(tonumber(num))
    end
    return row
end

---@param input string
---@return integer
local function checksum(input)
    local v = 0
    for line in input:gmatch('[^\r\n]+') do
        local row = parse(line)
        v = v + differences(row)
    end
    return v
end

---@param input string
---@return integer
local function checksum_v2(input)
    local v = 0
    for line in input:gmatch('[^\r\n]+') do
        local row = parse(line)
        v = v + division(row)
    end
    return v
end

local M = {}
M.parse = parse
M.differences = differences
M.division = division
M.checksum = checksum
M.checksum_v2 = checksum_v2
return M

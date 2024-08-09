local ffi = require('ffi')

ffi.cdef([[
int count_sum(const char* c, int len);
int count_sum_v2(const char* c, int len);
]])

local slib = ffi.load('solution')

---@param s string
---@return integer
local function count_sum(s)
    return slib.count_sum(s, #s)
end

---@param s string
---@return integer
local function count_sum_v2(s)
    return slib.count_sum_v2(s, #s)
end

local M = {}
M.count_sum = count_sum
M.count_sum_v2 = count_sum_v2
return M

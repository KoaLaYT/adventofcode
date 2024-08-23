local ffi = require('ffi')
ffi.cdef [[
int group_score(const char* s, int len);
int count_garbage(const char* s, int len);
]]
local clib = ffi.load('solution')

---@param s string
---@return integer
local function group_score(s)
    return clib.group_score(s, #s)
end

---@param s string
---@return integer
local function count_garbage(s)
    return clib.count_garbage(s, #s)
end

local M = {}
M.group_score = group_score
M.count_garbage = count_garbage
return M

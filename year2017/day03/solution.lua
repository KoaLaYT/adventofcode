local ffi = require('ffi')
ffi.cdef([[
int distance(int square);
int value(int target);
]])
local clib = ffi.load('solution')

---@param square integer
---@return integer
local function distance(square)
    local v = clib.distance(square)
    if v < 0 then error('bad dir') end
    return v
end

---@param target integer
---@return integer
local function value(target)
    local v = clib.value(target)
    if v < 0 then error('bad dir') end
    return v
end

local M = {}
M.distance = distance
M.value = value
return M

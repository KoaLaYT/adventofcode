local ffi = require('ffi')
ffi.cdef [[
int value_after(int step, int insertions);
int value_after_zero(int step, int insertions);
]]
local clib = ffi.load('solution')

---@param step integer
---@param insertions integer
---@return integer
local function value_after(step, insertions)
  return clib.value_after(step, insertions)
end

---@param step integer
---@param insertions integer
---@return integer
local function value_after_zero(step, insertions)
  return clib.value_after_zero(step, insertions)
end

local M = {}
M.value_after = value_after
M.value_after_zero = value_after_zero
return M

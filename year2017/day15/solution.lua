local ffi = require('ffi')
ffi.cdef [[
int judge_count(int start_a, int start_b, int round);
int judge_count2(int start_a, int start_b, int round);
]]
local clib = ffi.load('solution')

---@param start_a integer
---@param start_b integer
---@param round integer
---@return integer
local function judge_count(start_a, start_b, round)
  return clib.judge_count(start_a, start_b, round)
end

---@param start_a integer
---@param start_b integer
---@param round integer
---@return integer
local function judge_count2(start_a, start_b, round)
  return clib.judge_count2(start_a, start_b, round)
end

local M = {}
M.judge_count = judge_count
M.judge_count2 = judge_count2
return M

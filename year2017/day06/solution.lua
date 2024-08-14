local ffi = require('ffi')
ffi.cdef([[
typedef struct cycle_info {
    int cycle;
    int loop;
} cycle_info_t;

cycle_info_t redistribution_cycles(int* block, int len);
]])
local clib = ffi.load('solution')

---@param blocks integer[]
---@return integer cycle, integer loop
local function redistribution_cycles(blocks)
    local a = ffi.new('int[?]', #blocks, blocks)
    local v = clib.redistribution_cycles(a, #blocks)
    return v.cycle, v.loop
end

local M = {}
M.redistribution_cycles = redistribution_cycles
return M

local ffi = require('ffi')
ffi.cdef([[
int jump_steps(int* list, int len);
int jump_steps_v2(int* list, int len);
]])
local clib = ffi.load('solution')

---@param list integer[]
---@return integer
local function jump_steps(list)
    local v = ffi.new('int[?]', #list, list)
    return clib.jump_steps(v, #list)
end

---@param list integer[]
---@return integer
local function jump_steps_v2(list)
    local v = ffi.new('int[?]', #list, list)
    return clib.jump_steps_v2(v, #list)
end

---@param input string
---@return integer[]
local function parse_input(input)
    local list = {}
    for line in input:gmatch('[^\r\n]+') do
        local v = assert(tonumber(line))
        list[#list + 1] = v
    end
    return list
end

local M = {}
M.parse_input = parse_input
M.jump_steps = jump_steps
M.jump_steps_v2 = jump_steps_v2
return M

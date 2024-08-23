local ffi = require('ffi')
ffi.cdef [[
int knot_hash(int* input, int len, int list_size);
const char* full_knot_hash(const char* input, int len);
]]
local clib = ffi.load('solution')

---@param input integer[]
---@param list_size integer?
---@return integer
local function knot_hash(input, list_size)
    list_size = list_size or 256
    local a = ffi.new('int[?]', #input, input)
    return clib.knot_hash(a, #input, list_size)
end

---@param input string
---@return integer
local function full_knot_hash(input)
    input = input .. string.char(17, 31, 73, 47, 23)
    local hash = clib.full_knot_hash(input, #input)
    return ffi.string(hash, 32)
end

local M = {}
M.knot_hash = knot_hash
M.full_knot_hash = full_knot_hash
return M

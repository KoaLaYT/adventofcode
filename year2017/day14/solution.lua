local ffi = require('ffi')
ffi.cdef [[
const char* full_knot_hash(const char* input, int len);
]]
local clib = ffi.load('solution')

---@param input string
---@return string
local function full_knot_hash(input)
  input = input .. string.char(17, 31, 73, 47, 23)
  local hash = clib.full_knot_hash(input, #input)
  return ffi.string(hash, 128)
end

---@param key string
---@return integer
local function used_squares(key)
  local used = 0
  for i = 0, 127 do
    local input = string.format('%s-%d', key, i)
    local hash = full_knot_hash(input)
    for j = 1, #hash do
      local c = hash:byte(j, j)
      if c == string.byte('1') then used = used + 1 end
    end
  end
  return used
end

---@param grid boolean[][]
---@param row integer
---@param col integer
local function walk(grid, row, col)
  -- out of range
  if row < 1 or row > 128 or col < 1 or col > 128 then
    return
  end

  -- walked or not adjacent
  if not grid[row][col] then return end

  grid[row][col] = false
  walk(grid, row - 1, col)
  walk(grid, row + 1, col)
  walk(grid, row, col - 1)
  walk(grid, row, col + 1)
end

---@param key string
---@return integer
local function count_regions(key)
  local grid = {}
  for i = 0, 127 do
    local row = {}
    local input = string.format('%s-%d', key, i)
    local hash = full_knot_hash(input)
    for j = 1, #hash do
      local c = hash:byte(j, j)
      if c == string.byte('1') then
        table.insert(row, true)
      else
        table.insert(row, false)
      end
    end
    table.insert(grid, row)
  end

  local regions = 0
  for row = 1, #grid do
    for col = 1, 128 do
      if grid[row][col] then
        walk(grid, row, col)
        regions = regions + 1
      end
    end
  end

  return regions
end

local M = {}
M.full_knot_hash = full_knot_hash
M.used_squares = used_squares
M.count_regions = count_regions
return M

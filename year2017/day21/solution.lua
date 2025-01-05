local DOT_BYTE = string.byte('.')
local HASH_BYTE = string.byte('#')
local SLASH_BYTE = string.byte('/')

---@class Square
---@field size integer
---@field grid boolean[][]
local Square = {}
Square.__index = Square

---@param grid boolean[][]
---@return Square
function Square:new(grid)
  return setmetatable({ size = #grid, grid = grid, }, self)
end

---@param str string
---@return Square
function Square:from_str(str)
  local grid = {}
  for part in str:gmatch('[^/]+') do
    local row = {}
    for char in part:gmatch('.') do
      local byte = string.byte(char)
      table.insert(row, byte == HASH_BYTE)
    end
    table.insert(grid, row)
  end
  return Square:new(grid)
end

---@return string
function Square:concise()
  local str = {}
  for i = 1, self.size do
    if i > 1 then
      table.insert(str, SLASH_BYTE)
    end
    for j = 1, self.size do
      if self.grid[i][j] then
        table.insert(str, HASH_BYTE)
      else
        table.insert(str, DOT_BYTE)
      end
    end
  end
  return string.char(unpack(str))
end

---@return Square
function Square:rotate_left()
  local grid = {}
  for _ = 1, self.size do
    table.insert(grid, {})
  end

  for i = 1, self.size do
    for j = 1, self.size do
      grid[self.size - j + 1][i] = self.grid[i][j]
    end
  end

  return Square:new(grid)
end

---@return Square
function Square:rotate_right()
  local grid = {}
  for _ = 1, self.size do
    table.insert(grid, {})
  end

  for i = 1, self.size do
    for j = 1, self.size do
      grid[j][self.size - i + 1] = self.grid[i][j]
    end
  end

  return Square:new(grid)
end

function Square:flip_y()
  local grid = {}
  for _ = 1, self.size do
    table.insert(grid, {})
  end

  for i = 1, self.size do
    for j = 1, self.size do
      grid[i][self.size - j + 1] = self.grid[i][j]
    end
  end

  return Square:new(grid)
end

function Square:flip_x()
  local grid = {}
  for _ = 1, self.size do
    table.insert(grid, {})
  end

  for i = 1, self.size do
    for j = 1, self.size do
      grid[self.size - i + 1][j] = self.grid[i][j]
    end
  end

  return Square:new(grid)
end

---@return integer
function Square:ons()
  local result = 0
  for i = 1, self.size do
    for j = 1, self.size do
      if self.grid[i][j] then
        result = result + 1
      end
    end
  end
  return result
end

---@param grid boolean[][]
---@param x integer
---@param y integer
---@param rule string
local function put_into(grid, x, y, rule)
  local i = 0
  for part in rule:gmatch('[^/]+') do
    local j = 0
    for char in part:gmatch('.') do
      local byte = string.byte(char)
      if grid[x + i] == nil then
        table.insert(grid, x + i, {})
      end
      grid[x + i][y + j] = byte == HASH_BYTE
      j = j + 1
    end
    i = i + 1
  end
end

---@param x integer
---@param y integer
---@param size integer
---@return string
function Square:pattern(x, y, size)
  local bytes = {}
  for i = 1, size do
    if i > 1 then
      table.insert(bytes, SLASH_BYTE)
    end
    for j = 1, size do
      if self.grid[x + i - 1][y + j - 1] then
        table.insert(bytes, HASH_BYTE)
      else
        table.insert(bytes, DOT_BYTE)
      end
    end
  end
  return string.char(unpack(bytes))
end

---@param rules table<string, string>
---@return Square
function Square:expand(rules)
  local size = self.size % 2 == 0 and 2 or 3

  local grid = {}
  for i = 1, self.size / size do
    for j = 1, self.size / size do
      local x = size * (i - 1) + 1
      local y = size * (j - 1) + 1
      local pattern = self:pattern(x, y, size)
      local rule = rules[pattern]
      if rule == nil then
        error(string.format('no rule found for %s', pattern))
      end
      local expand_size = rule:find('/') - 1
      put_into(grid, expand_size * (i - 1) + 1, expand_size * (j - 1) + 1, rule)
    end
  end

  return Square:new(grid)
end

---@param input string
---@return table<string, string>
local function build_rules(input)
  local rules = {}
  for line in input:gmatch('[^\r\n]+') do
    local i = line:find(' => ')
    local left = line:sub(1, i - 1)
    local right = line:sub(i + 4)
    local s = Square:from_str(left)
    rules[s:concise()] = right
    rules[s:rotate_left():concise()] = right
    rules[s:rotate_left():flip_x():concise()] = right
    rules[s:rotate_left():flip_y():concise()] = right
    rules[s:rotate_right():concise()] = right
    rules[s:rotate_left():rotate_left():concise()] = right
    rules[s:rotate_left():rotate_left():rotate_left():concise()] = right
    rules[s:rotate_right():rotate_right():concise()] = right
    rules[s:rotate_right():rotate_right():rotate_right():concise()] = right
    rules[s:flip_x():concise()] = right
    rules[s:flip_y():concise()] = right
  end
  return rules
end

---@param input string
---@param round integer
---@return integer
local function expand(input, round)
  local rules = build_rules(input)
  local s = Square:from_str('.#./..#/###')
  for _ = 1, round do
    s = s:expand(rules)
  end
  return s:ons()
end

local M = {}
M.Square = Square
M.build_rules = build_rules
M.expand = expand
return M

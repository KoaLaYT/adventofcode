---@class Route
---@field grid integer[][]
---@field row integer
---@field col integer
local Route = {}
Route.__index = Route

local CHAR_SPACE = string.byte(' ')
local CHAR_VBAR = string.byte('|')
local CHAR_HBAR = string.byte('-')
local CHAR_PLUS = string.byte('+')

function Route:_print()
  for i = 1, self.row do
    print(string.char(unpack(self.grid[i])))
  end
end

---@param input string
---@return Route
function Route:new(input)
  -- first pass, find row/col
  local row = 0
  local col = 0
  for line in input:gmatch('[^\r\n]+') do
    row = row + 1
    col = math.max(col, #line)
  end

  local grid = {}
  for i = 1, row do
    local line = {}
    for j = 1, col do
      table.insert(line, CHAR_SPACE)
    end
    table.insert(grid, line)
  end

  local cur_row = 0
  for line in input:gmatch('[^\r\n]+') do
    cur_row = cur_row + 1
    for i = 1, #line do
      local char = string.byte(line, i, i)
      if char == CHAR_SPACE then
        -- do nothing
      else
        grid[cur_row][i] = char
      end
    end
  end

  return setmetatable({
    grid = grid,
    row = row,
    col = col,
  }, self)
end

---@return integer x, integer y
function Route:_find_start()
  for j = 1, self.col do
    if self.grid[1][j] == CHAR_VBAR then
      return 1, j
    end
  end
  error('cannot find start')
end

---@class Walker
---@field route Route
---@field x integer
---@field y integer
---@field x_dir -1|0|1
---@field y_dir -1|0|1
local Walker = {}
Walker.__index = Walker

---@param route Route
---@return Walker
function Walker:new(route)
  local x, y = route:_find_start()
  return setmetatable({
    route = route,
    x = x,
    y = y,
    x_dir = 1,
    y_dir = 0,
  }, self)
end

---@return integer
function Walker:at()
  local x, y = self.x, self.y
  if x < 1 or x > self.route.row or y < 1 or y > self.route.col then
    error(string.format('walker out of bound: (%d,%d)', x, y))
  end
  return self.route.grid[x][y]
end

---@return boolean has_end
function Walker:next()
  self.x = self.x + self.x_dir
  self.y = self.y + self.y_dir

  local out_bound = self.x < 1 or self.x > self.route.row or self.y < 1 or self.y > self.route.col
  if out_bound then return true end
  return self.route.grid[self.x][self.y] == CHAR_SPACE
end

-- at '+', determine next dir
function Walker:turn()
  local x, y = self.x, self.y
  -- prev go vertical
  if self.y_dir == 0 and self.x_dir ~= 0 then
    if y - 1 >= 1 and self.route.grid[x][y - 1] ~= CHAR_SPACE then
      self.x_dir = 0
      self.y_dir = -1
    elseif y + 1 <= self.route.col and self.route.grid[x][y + 1] ~= CHAR_SPACE then
      self.x_dir = 0
      self.y_dir = 1
    else
      error(string.format('cannot turn left/right at (%d,%d)', x, y))
    end
    -- prev go horizonal
  elseif self.x_dir == 0 and self.y_dir ~= 0 then
    if x - 1 >= 1 and self.route.grid[x - 1][y] ~= CHAR_SPACE then
      self.x_dir = -1
      self.y_dir = 0
    elseif x + 1 <= self.route.row and self.route.grid[x + 1][y] ~= CHAR_SPACE then
      self.x_dir = 1
      self.y_dir = 0
    else
      error(string.format('cannot turn left/right at (%d,%d)', x, y))
    end
  else
    error(string.format('cannot turn at (%d,%d)', x, y))
  end
end

---@return string
function Route:letters()
  ---@type integer[]
  local letters = {}
  local walker = Walker:new(self)

  while true do
    local p = walker:at()
    if p == CHAR_PLUS then
      walker:turn()
    elseif p ~= CHAR_HBAR and p ~= CHAR_VBAR and p ~= CHAR_SPACE then
      table.insert(letters, p)
    end
    local has_end = walker:next()
    if has_end then break end
  end

  return string.char(unpack(letters))
end

---@return integer
function Route:steps()
  local steps = 0
  local walker = Walker:new(self)

  while true do
    steps = steps + 1
    local p = walker:at()
    if p == CHAR_PLUS then
      walker:turn()
    end
    local has_end = walker:next()
    if has_end then break end
  end

  return steps
end

local M = {}
M.Route = Route
return M

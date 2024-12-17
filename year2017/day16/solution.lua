---@class Spin
---@field x integer
local Spin = {}
Spin.__index = Spin

---@param x integer
---@return Spin
function Spin:new(x)
  return setmetatable({ x = x, }, self)
end

---@param arr integer[]
---@param aux integer[]
function Spin:exec(arr, aux)
  for i = 1, #arr do
    if i <= #arr - self.x then
      aux[i + self.x] = arr[i]
    else
      aux[i - (#arr - self.x)] = arr[i]
    end
  end
  for i = 1, #arr do
    arr[i] = aux[i]
  end
end

---@class Exchange
---@field a integer
---@field b integer
local Exchange = {}
Exchange.__index = Exchange

---@param a integer
---@param b integer
---@return Exchange
function Exchange:new(a, b)
  return setmetatable({ a = a + 1, b = b + 1, }, self)
end

---@param arr integer[]
---@param aux integer[]
function Exchange:exec(arr, aux)
  local tmp = arr[self.a]
  arr[self.a] = arr[self.b]
  arr[self.b] = tmp
end

---@class Partner
---@field a integer
---@field b integer
local Partner = {}
Partner.__index = Partner
---
---@param a integer
---@param b integer
---@return Partner
function Partner:new(a, b)
  return setmetatable({ a = a, b = b, }, self)
end

---@param arr integer[]
---@param aux integer[]
function Partner:exec(arr, aux)
  local i, j;
  for k, v in ipairs(arr) do
    if v == self.a then
      i = k
    elseif v == self.b then
      j = k
    end
  end

  local tmp = arr[i]
  arr[i] = arr[j]
  arr[j] = tmp
end

---@alias Command Spin|Exchange|Partner

---@param s string
---@return integer
local function must_tonumber(s)
  return assert(tonumber(s))
end

---@param input string
---@return Command[]
local function parse_commands(input)
  local commands = {}
  for command in input:gmatch('[^,]+') do
    if command:sub(1, 1) == 's' then
      local x = must_tonumber(command:sub(2))
      table.insert(commands, Spin:new(x))
    elseif command:sub(1, 1) == 'x' then
      local i = command:find('/')
      local a = must_tonumber(command:sub(2, i - 1))
      local b = must_tonumber(command:sub(i + 1))
      table.insert(commands, Exchange:new(a, b))
    elseif command:sub(1, 1) == 'p' then
      local i = command:find('/')
      local a = string.byte(command:sub(2, i - 1))
      local b = string.byte((command:sub(i + 1)))
      table.insert(commands, Partner:new(a, b))
    else
      error(string.format('unknown command: %s', command))
    end
  end
  return commands
end

---@param arr integer[]
---@param input string
---@return string
local function dance(arr, input)
  local aux = {}
  local commands = parse_commands(input)
  for _, command in ipairs(commands) do
    command:exec(arr, aux)
  end
  return string.char(unpack(arr))
end

---@param arr integer[]
---@param input string
---@param round integer
---@return string
local function dance2(arr, input, round)
  local aux = {}
  local commands = parse_commands(input)

  local i = 1
  while true do
    for _, command in ipairs(commands) do
      command:exec(arr, aux)
    end
    if string.char(unpack(arr)) == 'abcdefghijklmnop' then
      break
    end
    i = i + 1
  end

  round = round % i
  for _ = 1, round do
    for _, command in ipairs(commands) do
      command:exec(arr, aux)
    end
  end
  return string.char(unpack(arr))
end

local M = {}
M.Spin = Spin
M.Exchange = Exchange
M.Partner = Partner
M.dance = dance
M.dance2 = dance2
return M

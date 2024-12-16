---@param s string
---@return integer
local function must_tonumber(s)
  return assert(tonumber(s))
end

---@class Layer
---@field range integer
---@field index integer
---@field dir 1 | -1
local Layer = {}
Layer.__index = Layer

---@param range integer
---@return Layer
function Layer:new(range)
  return setmetatable({
    range = range,
    index = 0,
    dir = 1,
  }, self)
end

---@param sec integer
function Layer:seek(sec)
  local size = self.range * 2 - 2
  local i = sec % size
  if i >= self.range - 1 then
    self.index = (self.range - 1) - (i - (self.range - 1))
    self.dir = -1
  else
    self.index = i
    self.dir = 1
  end
end

---@class Firewall
---@field layers table<integer,Layer>
---@field max_layer integer
local Firewall = {}
Firewall.__index = Firewall

---@param input string
---@return Firewall
function Firewall:new(input)
  local layers = {}
  local max_layer = 0
  for line in input:gmatch('[^\r\n]+') do
    local is_first = true
    local depth = 0
    for num in line:gmatch('%d+') do
      if is_first then
        depth = must_tonumber(num)
        is_first = false
      else
        layers[depth] = Layer:new(must_tonumber(num))
        max_layer = depth
      end
    end
  end
  return setmetatable({
    layers = layers,
    max_layer = max_layer,
  }, self)
end

---@param delay integer
function Firewall:scan(delay)
  local found = false
  local severity = 0
  for depth, layer in pairs(self.layers) do
    layer:seek(depth + delay)
    if layer.index == 0 then
      found = true
      severity = severity + depth * layer.range
    end
  end
  return found, severity
end

---@param delay integer
function Firewall:is_caught(delay)
  for depth, layer in pairs(self.layers) do
    layer:seek(depth + delay)
    if layer.index == 0 then
      return true
    end
  end
  return false
end

---@param input string
---@return integer
local function travel(input)
  local firewall    = Firewall:new(input)
  local _, severity = firewall:scan(0)
  return severity
end


---@param input string
---@return integer
local function fewest_uncaught(input)
  local firewall = Firewall:new(input)
  local delay = 0
  while true do
    local is_caught = firewall:is_caught(delay)
    if is_caught then
      delay = delay + 1
    else
      return delay
    end
  end
end

local M = {}
M.Layer = Layer
M.travel = travel
M.fewest_uncaught = fewest_uncaught
return M

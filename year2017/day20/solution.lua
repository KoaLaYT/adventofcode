---@class Point
---@field x integer
---@field y integer
---@field z integer
local Point = {}
Point.__index = Point

---@param input string
---@return Point
function Point:new(input)
  local d = {}
  for v in input:gmatch('-?%d+') do
    table.insert(d, assert(tonumber(v)))
  end
  return setmetatable({ x = d[1], y = d[2], z = d[3], }, self)
end

---@return string
function Point:__tostring()
  return string.format('(%d,%d,%d)', self.x, self.y, self.z)
end

---@param other Point
function Point:add(other)
  self.x = self.x + other.x
  self.y = self.y + other.y
  self.z = self.z + other.z
end

---@class Particle
---@field p Point
---@field v Point
---@field a Point
local Particle = {}
Particle.__index = Particle

---@param input string
function Particle:new(input)
  local i = input:find(', ')
  local j = input:sub(i + 2):find(', ')
  local rp = input:sub(4, i - 2)
  local rv = input:sub(i + 5, i + j - 1)
  local ra = input:sub(i + j + 6, #input - 1)
  return setmetatable({
    p = Point:new(rp),
    v = Point:new(rv),
    a = Point:new(ra),
  }, self)
end

---@return integer
function Particle:distance()
  return math.abs(self.p.x) + math.abs(self.p.y) + math.abs(self.p.z)
end

---@param t integer
function Particle:tick(t)
  for _ = 1, t do
    self:update()
  end
end

function Particle:update()
  self.v:add(self.a)
  self.p:add(self.v)
end

---@param input string
---@return integer
local function closest(input)
  local round = 1000
  local min_distance = math.huge
  local id = 0
  local result = 0
  for row in input:gmatch('[^\r\n]+') do
    local p = Particle:new(row)
    p:tick(round)
    local d = p:distance()
    if d < min_distance then
      min_distance = d
      result = id
    end
    id = id + 1
  end
  return result
end

---@param ps Particle[]
---@return Particle[]
local function remove_collides(ps)
  ---@type table<string, integer[]>
  local map = {}

  for i, p in ipairs(ps) do
    local key = string.format('%s', p.p)
    local v = map[key] or {}
    table.insert(v, i)
    map[key] = v
  end

  local result = {}
  for _, v in pairs(map) do
    if #v == 1 then
      table.insert(result, ps[v[1]])
    end
  end
  return result
end

---@param input string
---@return integer
local function left(input)
  local ps = {}
  for row in input:gmatch('[^\r\n]+') do
    local p = Particle:new(row)
    table.insert(ps, p)
  end

  for _ = 1, 1000 do
    ps = remove_collides(ps)
    if #ps <= 1 then break end

    for _, p in ipairs(ps) do
      p:update()
    end
  end

  return #ps
end

local M = {}
M.Particle = Particle
M.closest = closest
M.left = left
return M

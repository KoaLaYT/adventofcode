local State = {
  Clean = 0,
  Infected = 1,
  Weakened = 2,
  Flagged = 3,
}

---@class Virus
---@field map table<string,integer>
---@field x integer
---@field y integer
---@field x_dir -1|0|1
---@field y_dir -1|0|1
local Virus = {}
Virus.__index = Virus

---@param input string
---@return Virus
function Virus:new(input)
  local map = {}
  local x = 0
  for line in input:gmatch('[^\r\n]+') do
    x = x + 1
    local y = 0
    for char in line:gmatch('.') do
      y = y + 1
      if char == '#' then
        map[string.format('%d,%d', x, y)] = State.Infected
      end
    end
  end
  return setmetatable({
    map = map,
    x = (x + 1) / 2,
    y = (x + 1) / 2,
    x_dir = -1,
    y_dir = 0,
  }, self)
end

function Virus:_turn_right()
  if self.x_dir == 0 and self.y_dir == -1 then
    self.y_dir = 0
    self.x_dir = -1
  elseif self.x_dir == 0 and self.y_dir == 1 then
    self.y_dir = 0
    self.x_dir = 1
  elseif self.y_dir == 0 and self.x_dir == -1 then
    self.x_dir = 0
    self.y_dir = 1
  elseif self.y_dir == 0 and self.x_dir == 1 then
    self.x_dir = 0
    self.y_dir = -1
  end
end

function Virus:_turn_left()
  if self.x_dir == 0 and self.y_dir == -1 then
    self.y_dir = 0
    self.x_dir = 1
  elseif self.x_dir == 0 and self.y_dir == 1 then
    self.y_dir = 0
    self.x_dir = -1
  elseif self.y_dir == 0 and self.x_dir == -1 then
    self.x_dir = 0
    self.y_dir = -1
  elseif self.y_dir == 0 and self.x_dir == 1 then
    self.x_dir = 0
    self.y_dir = 1
  end
end

function Virus:_turn_around()
  self.x_dir = -self.x_dir
  self.y_dir = -self.y_dir
end

function Virus:_forward()
  self.x = self.x + self.x_dir
  self.y = self.y + self.y_dir
end

---@param bursts integer
---@return integer
function Virus:infected_after(bursts)
  local infected = 0
  for _ = 1, bursts do
    local key = string.format('%d,%d', self.x, self.y)
    if self.map[key] == State.Infected then
      self:_turn_right()
      self.map[key] = State.Clean
    else
      self:_turn_left()
      infected = infected + 1
      self.map[key] = State.Infected
    end
    self:_forward()
  end
  return infected
end

---@param bursts integer
---@return integer
function Virus:evolved_infected_after(bursts)
  local infected = 0
  for _ = 1, bursts do
    local key = string.format('%d,%d', self.x, self.y)
    if self.map[key] == nil or self.map[key] == State.Clean then
      self.map[key] = State.Weakened
      self:_turn_left()
    elseif self.map[key] == State.Weakened then
      self.map[key] = State.Infected
      infected = infected + 1
    elseif self.map[key] == State.Infected then
      self.map[key] = State.Flagged
      self:_turn_right()
    elseif self.map[key] == State.Flagged then
      self.map[key] = State.Clean
      self:_turn_around()
    end
    self:_forward()
  end
  return infected
end

local M = {}
M.Virus = Virus
return M

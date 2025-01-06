---@class State
---@field w0 integer
---@field m0 -1 | 1
---@field s0 string
---@field w1 integer
---@field m1 -1 | 1
---@field s1 string
local State = {}
State.__index = State

---@param w0 integer
---@param m0 -1 | 1
---@param s0 string
---@param w1 integer
---@param m1 -1 | 1
---@param s1 string
---@return State
function State:new(w0, m0, s0, w1, m1, s1)
  return setmetatable({
    w0 = w0,
    m0 = m0,
    s0 = s0,
    w1 = w1,
    m1 = m1,
    s1 = s1,
  }, self)
end

---@param machine Machine
function State:exec(machine)
  local v = machine.values[machine.pos] or 0
  if v == 0 then
    machine.values[machine.pos] = self.w0
    machine.pos = machine.pos + self.m0
    machine.curr_state = self.s0
  else
    machine.values[machine.pos] = self.w1
    machine.pos = machine.pos + self.m1
    machine.curr_state = self.s1
  end
end

---@class Machine
---@field steps integer
---@field states table<string, State>
---@field curr_state string
---@field pos integer
---@field values table<integer, integer>
local Machine = {}
Machine.__index = Machine

---@param steps integer
---@param states table<string, State>
---@return Machine
function Machine:new(steps, states)
  return setmetatable({
    steps = steps,
    states = states,
    curr_state = 'A',
    pos = 0,
    values = {},
  }, self)
end

---@return integer
function Machine:run()
  for _ = 1, self.steps do
    self.states[self.curr_state]:exec(self)
  end

  local checksum = 0
  for k, v in pairs(self.values) do
    if v == 1 then checksum = checksum + 1 end
  end
  return checksum
end

local M = {}
M.State = State
M.Machine = Machine
return M


---
--- InsSnd
---
---@class InsSnd
---@field reg integer
local InsSnd = {}
InsSnd.__index = InsSnd

---@param reg integer
---@return InsSnd
function InsSnd:new(reg)
  return setmetatable({ reg = reg, }, self)
end

---@param tablet Tablet
---@return boolean is_rcv_nonzero
function InsSnd:exec(tablet)
  local v = tablet.regs[self.reg] or 0
  tablet.last_snd = v
  tablet.p = tablet.p + 1
  return false
end

---
--- InsSnd2
---
---@class InsSnd2
---@field reg integer
local InsSnd2 = {}
InsSnd2.__index = InsSnd2

---@param reg integer
---@return InsSnd2
function InsSnd2:new(reg)
  return setmetatable({ reg = reg, }, self)
end

---@param tablet Tablet
---@return boolean is_terminated, integer value
function InsSnd2:exec(tablet)
  local v = tablet.regs[self.reg] or 0
  tablet.p = tablet.p + 1
  return false, v
end

---
--- InsSetV
---
---@class InsSetV
---@field reg integer
---@field val integer
local InsSetV = {}
InsSetV.__index = InsSetV

---@param reg integer
---@param val integer
---@return InsSetV
function InsSetV:new(reg, val)
  return setmetatable({ reg = reg, val = val, }, self)
end

---@param tablet Tablet
---@return boolean is_rcv_nonzero
function InsSetV:exec(tablet)
  tablet.regs[self.reg] = self.val
  tablet.p = tablet.p + 1
  return false
end

---
--- InsSetR
---
---@class InsSetR
---@field reg1 integer
---@field reg2 integer
local InsSetR = {}
InsSetR.__index = InsSetR

---@param reg1 integer
---@param reg2 integer
---@return InsSetR
function InsSetR:new(reg1, reg2)
  return setmetatable({ reg1 = reg1, reg2 = reg2, }, self)
end

---@param tablet Tablet
---@return boolean is_rcv_nonzero
function InsSetR:exec(tablet)
  local v = tablet.regs[self.reg2] or 0
  tablet.regs[self.reg1] = v
  tablet.p = tablet.p + 1
  return false
end

---
--- InsAddV
---
---@class InsAddV
---@field reg integer
---@field val integer
local InsAddV = {}
InsAddV.__index = InsAddV

---@param reg integer
---@param val integer
---@return InsAddV
function InsAddV:new(reg, val)
  return setmetatable({ reg = reg, val = val, }, self)
end

---@param tablet Tablet
---@return boolean is_rcv_nonzero
function InsAddV:exec(tablet)
  local v = tablet.regs[self.reg] or 0
  tablet.regs[self.reg] = v + self.val
  tablet.p = tablet.p + 1
  return false
end

---
--- InsAddR
---
---@class InsAddR
---@field reg1 integer
---@field reg2 integer
local InsAddR = {}
InsAddR.__index = InsAddR

---@param reg1 integer
---@param reg2 integer
---@return InsAddR
function InsAddR:new(reg1, reg2)
  return setmetatable({ reg1 = reg1, reg2 = reg2, }, self)
end

---@param tablet Tablet
---@return boolean is_rcv_nonzero
function InsAddR:exec(tablet)
  local v1 = tablet.regs[self.reg1] or 0
  local v2 = tablet.regs[self.reg2] or 0
  tablet.regs[self.reg1] = v1 + v2
  tablet.p = tablet.p + 1
  return false
end

---
--- InsMulV
---
---@class InsMulV
---@field reg integer
---@field val integer
local InsMulV = {}
InsMulV.__index = InsMulV

---@param reg integer
---@param val integer
---@return InsMulV
function InsMulV:new(reg, val)
  return setmetatable({ reg = reg, val = val, }, self)
end

---@param tablet Tablet
---@return boolean is_rcv_nonzero
function InsMulV:exec(tablet)
  local v = tablet.regs[self.reg] or 0
  tablet.regs[self.reg] = v * self.val
  tablet.p = tablet.p + 1
  return false
end

---
--- InsMulR
---
---@class InsMulR
---@field reg1 integer
---@field reg2 integer
local InsMulR = {}
InsMulR.__index = InsMulR

---@param reg1 integer
---@param reg2 integer
---@return InsMulR
function InsMulR:new(reg1, reg2)
  return setmetatable({ reg1 = reg1, reg2 = reg2, }, self)
end

---@param tablet Tablet
---@return boolean is_rcv_nonzero
function InsMulR:exec(tablet)
  local v1 = tablet.regs[self.reg1] or 0
  local v2 = tablet.regs[self.reg2] or 0
  tablet.regs[self.reg1] = v1 * v2
  tablet.p = tablet.p + 1
  return false
end

---
--- InsModV
---
---@class InsModV
---@field reg integer
---@field val integer
local InsModV = {}
InsModV.__index = InsModV

---@param reg integer
---@param val integer
---@return InsModV
function InsModV:new(reg, val)
  return setmetatable({ reg = reg, val = val, }, self)
end

---@param tablet Tablet
---@return boolean is_rcv_nonzero
function InsModV:exec(tablet)
  local v = tablet.regs[self.reg] or 0
  tablet.regs[self.reg] = v % self.val
  tablet.p = tablet.p + 1
  return false
end

---
--- InsModR
---
---@class InsModR
---@field reg1 integer
---@field reg2 integer
local InsModR = {}
InsModR.__index = InsModR

---@param reg1 integer
---@param reg2 integer
---@return InsModR
function InsModR:new(reg1, reg2)
  return setmetatable({ reg1 = reg1, reg2 = reg2, }, self)
end

---@param tablet Tablet
---@return boolean is_rcv_nonzero
function InsModR:exec(tablet)
  local v1 = tablet.regs[self.reg1] or 0
  local v2 = tablet.regs[self.reg2] or 0
  tablet.regs[self.reg1] = v1 % v2
  tablet.p = tablet.p + 1
  return false
end

---
--- InsRcvR
---
---@class InsRcvR
---@field reg integer
local InsRcvR = {}
InsRcvR.__index = InsRcvR

---@param reg integer
---@return InsRcvR
function InsRcvR:new(reg)
  return setmetatable({ reg = reg, }, self)
end

---@param tablet Tablet
---@return boolean is_rcv_nonzero
function InsRcvR:exec(tablet)
  local v = tablet.regs[self.reg] or 0
  tablet.p = tablet.p + 1
  return v ~= 0
end

---
--- InsRcv2
---
---@class InsRcv2
---@field reg integer
local InsRcv2 = {}
InsRcv2.__index = InsRcv2

---@param reg integer
---@return InsRcv2
function InsRcv2:new(reg)
  return setmetatable({ reg = reg, }, self)
end

---@param tablet Tablet
---@return boolean is_terminated
function InsRcv2:exec(tablet)
  if #tablet.mq < 1 then
    return true
  end
  local v = table.remove(tablet.mq, 1)
  tablet.regs[self.reg] = v
  tablet.p = tablet.p + 1
  return false
end

---
--- InsJgz
---
---@class InsJgz
---@field v1 integer
---@field v2 integer
local InsJgz = {}
InsJgz.__index = InsJgz

---@param v1 integer
---@param v2 integer
---@return InsJgz
function InsJgz:new(v1, v2)
  return setmetatable({ v1 = v1, v2 = v2, }, self)
end

---@param tablet Tablet
---@return boolean is_rcv_nonzero
function InsJgz:exec(tablet)
  local offset = 0
  if self.v1 > 0 then
    offset = self.v2
  end
  tablet.p = tablet.p + offset
  return false
end

---
--- InsJgzV
---
---@class InsJgzV
---@field reg integer
---@field val integer
local InsJgzV = {}
InsJgzV.__index = InsJgzV

---@param reg integer
---@param val integer
---@return InsJgzV
function InsJgzV:new(reg, val)
  return setmetatable({ reg = reg, val = val, }, self)
end

---@param tablet Tablet
---@return boolean is_rcv_nonzero
function InsJgzV:exec(tablet)
  local v = tablet.regs[self.reg] or 0
  local offset = 1
  if v > 0 then
    offset = self.val
  end
  tablet.p = tablet.p + offset
  return false
end

---
--- InsJgzR
---
---@class InsJgzR
---@field reg1 integer
---@field reg2 integer
local InsJgzR = {}
InsJgzR.__index = InsJgzR

---@param reg1 integer
---@param reg2 integer
---@return InsJgzR
function InsJgzR:new(reg1, reg2)
  return setmetatable({ reg1 = reg1, reg2 = reg2, }, self)
end

---@param tablet Tablet
---@return boolean is_rcv_nonzero
function InsJgzR:exec(tablet)
  local v = tablet.regs[self.reg1] or 0
  local offset = 1
  if v > 0 then
    offset = tablet.regs[self.reg2] or 0
  end
  tablet.p = tablet.p + offset
  return false
end

---@alias Instruction InsSnd|InsSnd2|InsSetV|InsSetR|InsAddV|InsAddR|InsMulV|InsMulR|InsModV|InsModR|InsRcvR|InsRcv2|InsJgzV|InsJgzR|InsJgz

---@class Tablet
---@field instructions Instruction[]
---@field regs table<integer,integer>
---@field last_snd integer
---@field mq integer[]
---@field p integer
local Tablet = {}
Tablet.__index = Tablet

---@param input string
---@param version? 1 | 2
---@return Tablet
function Tablet:new(input, version)
  version = version or 1
  ---@type Instruction[]
  local instructions = {}

  for line in input:gmatch('[^\r\n]+') do
    local parts = {}
    for part in line:gmatch('[^ ]+') do
      table.insert(parts, part)
    end
    local ins, reg, v_or_r = parts[1], string.byte(parts[2]), parts[3]
    if ins == 'snd' then
      if version == 1 then
        table.insert(instructions, InsSnd:new(reg))
      else
        table.insert(instructions, InsSnd2:new(reg))
      end
    elseif ins == 'set' then
      local v = tonumber(v_or_r)
      if v ~= nil then
        table.insert(instructions, InsSetV:new(reg, v))
      else
        table.insert(instructions, InsSetR:new(reg, string.byte(v_or_r)))
      end
    elseif ins == 'add' then
      local v = tonumber(v_or_r)
      if v ~= nil then
        table.insert(instructions, InsAddV:new(reg, v))
      else
        table.insert(instructions, InsAddR:new(reg, string.byte(v_or_r)))
      end
    elseif ins == 'mul' then
      local v = tonumber(v_or_r)
      if v ~= nil then
        table.insert(instructions, InsMulV:new(reg, v))
      else
        table.insert(instructions, InsMulR:new(reg, string.byte(v_or_r)))
      end
    elseif ins == 'mod' then
      local v = tonumber(v_or_r)
      if v ~= nil then
        table.insert(instructions, InsModV:new(reg, v))
      else
        table.insert(instructions, InsModR:new(reg, string.byte(v_or_r)))
      end
    elseif ins == 'rcv' then
      if version == 1 then
        table.insert(instructions, InsRcvR:new(reg))
      else
        table.insert(instructions, InsRcv2:new(reg))
      end
    elseif ins == 'jgz' then
      local v = tonumber(v_or_r)
      if reg == string.byte('1') then
        table.insert(instructions, InsJgz:new(1, assert(v)))
      else
        if v ~= nil then
          table.insert(instructions, InsJgzV:new(reg, v))
        else
          table.insert(instructions, InsJgzR:new(reg, string.byte(v_or_r)))
        end
      end
    else
      error(string.format('unknown ins %s', ins))
    end
  end

  return setmetatable({
    instructions = instructions,
    regs = {},
    last_snd = 0,
    mq = {},
    p = 1,
  }, self)
end

---@return integer
function Tablet:first_rcv_nonzero()
  while self.p <= #self.instructions do
    local ins = self.instructions[self.p]
    if ins:exec(self) then
      return self.last_snd
    end
  end
  error('No rcv executed with a non-zero value')
end

---@param other Tablet
---@return boolean has_exec, integer snd_count
function Tablet:exec(other)
  local has_exec = false
  local snd_count = 0
  while self.p <= #self.instructions do
    local ins = self.instructions[self.p]
    local has_terminated, v = ins:exec(self)
    if has_terminated then break end
    if v ~= nil then
      table.insert(other.mq, v)
      snd_count = snd_count + 1
    end
    has_exec = true
  end
  return has_exec, snd_count
end

---@return integer
local function run_two_tablets(input)
  local t0 = Tablet:new(input, 2)
  t0.regs[string.byte('p')] = 0

  local t1 = Tablet:new(input, 2)
  t1.regs[string.byte('p')] = 1

  local result = 0
  while true do
    local has_exec0 = t0:exec(t1)
    local has_exec1, snd_count = t1:exec(t0)
    result = result + snd_count
    if not has_exec0 and not has_exec1 then break end
  end
  return result
end

local M = {}
M.Tablet = Tablet
M.run_two_tablets = run_two_tablets
return M

---@alias Ins InsSet|InsSub|InsMul|InsJnz

---@class InsSet
---@field x string
---@field y string
local InsSet = {}
InsSet.__index = InsSet

---@param x string
---@param y string
---@return InsSet
function InsSet:new(x, y)
  return setmetatable({ x = x, y = y, }, self)
end

---@return string
function InsSet:name()
  return 'set'
end

---@param processor Processor
function InsSet:exec(processor)
  local v = tonumber(self.y)
  if v == nil then
    v = processor.regs[self.y] or 0
  end
  processor.regs[self.x] = v
  processor.p = processor.p + 1
end

---@class InsSub
---@field x string
---@field y string
local InsSub = {}
InsSub.__index = InsSub

---@param x string
---@param y string
---@return InsSub
function InsSub:new(x, y)
  return setmetatable({ x = x, y = y, }, self)
end

---@return string
function InsSub:name()
  return 'sub'
end

---@param processor Processor
function InsSub:exec(processor)
  local v = tonumber(self.y)
  if v == nil then
    v = processor.regs[self.y] or 0
  end
  processor.regs[self.x] = (processor.regs[self.x] or 0) - v
  processor.p = processor.p + 1
end

---@class InsMul
---@field x string
---@field y string
local InsMul = {}
InsMul.__index = InsMul

---@param x string
---@param y string
---@return InsMul
function InsMul:new(x, y)
  return setmetatable({ x = x, y = y, }, self)
end

---@return string
function InsMul:name()
  return 'mul'
end

---@param processor Processor
function InsMul:exec(processor)
  local v = tonumber(self.y)
  if v == nil then
    v = processor.regs[self.y] or 0
  end
  processor.regs[self.x] = (processor.regs[self.x] or 0) * v
  processor.p = processor.p + 1
end

---@class InsJnz
---@field x string
---@field y string
local InsJnz = {}
InsJnz.__index = InsJnz

---@param x string
---@param y string
---@return InsJnz
function InsJnz:new(x, y)
  return setmetatable({ x = x, y = y, }, self)
end

---@return string
function InsJnz:name()
  return 'jnz'
end

---@param processor Processor
function InsJnz:exec(processor)
  local x = tonumber(self.x)
  if x == nil then
    x = processor.regs[self.x] or 0
  end
  if x == 0 then
    processor.p = processor.p + 1
  else
    local y = tonumber(self.y)
    if y == nil then
      y = processor.regs[self.y] or 0
    end
    processor.p = processor.p + y
  end
end

---@class Processor
---@field ins Ins[]
---@field regs table<string, integer>
---@field p integer
local Processor = {}
Processor.__index = Processor

---@param input string
---@return Processor
function Processor:new(input)
  local instructions = {}
  for row in input:gmatch('[^\r\n]+') do
    local ins = row:sub(1, 3)
    local x = row:sub(5, 5)
    local y = row:sub(7)
    if ins == 'set' then
      table.insert(instructions, InsSet:new(x, y))
    elseif ins == 'sub' then
      table.insert(instructions, InsSub:new(x, y))
    elseif ins == 'mul' then
      table.insert(instructions, InsMul:new(x, y))
    elseif ins == 'jnz' then
      table.insert(instructions, InsJnz:new(x, y))
    else
      error(string.format('unknown %s: %s %s %s', row, ins, x, y))
    end
  end
  return setmetatable({
    ins = instructions,
    regs = {},
    p = 1,
  }, self)
end

---@return integer
function Processor:mul_invoked()
  local count = 0
  while self.p <= #self.ins do
    local ins = self.ins[self.p]
    ins:exec(self)
    if ins:name() == 'mul' then
      count = count + 1
    end
  end
  return count
end

---@param n integer
---@return boolean
local function is_prime(n)
  if n <= 1 then return false end
  for i = 2, n - 1 do
    if n % i == 0 then return false end
  end
  return true
end

---@return integer
function Processor:reverse_asm()
  local b = 108400
  local c = 125400
  local h = 0
  while b <= c do
    if not is_prime(b) then
      h = h + 1
    end
    b = b + 17
  end
  return h
end

local M = {}
M.Processor = Processor
return M

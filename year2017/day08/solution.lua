---@enum Checks
local CHECKS = {
    gt = 1,
    gte = 2,
    lt = 3,
    lte = 4,
    eq = 5,
    ne = 6,
}

local COND_CHECKS = {
    ['>'] = CHECKS.gt,
    ['>='] = CHECKS.gte,
    ['<'] = CHECKS.lt,
    ['<='] = CHECKS.lte,
    ['=='] = CHECKS.eq,
    ['!='] = CHECKS.ne,
}

local ACTIONS = {
    inc = 1,
    dec = -1,
}

---@class Instruction
---@field modify_reg string
---@field action 1 | -1 # 1 inc, -1 dec
---@field amount integer
---@field cond_reg string
---@field cond_check Checks
---@field cond_val integer
local Instruction = {}
Instruction.__index = Instruction

---@param s string
---@return integer
local function must_tonumber(s)
    return assert(tonumber(s))
end

---@param s string
---@return Instruction
function Instruction:new(s)
    local words = {}
    for w in s:gmatch('%S+') do
        table.insert(words, w)
    end

    return setmetatable({
        modify_reg = words[1],
        action = ACTIONS[words[2]],
        amount = must_tonumber(words[3]),
        cond_reg = words[5],
        cond_check = COND_CHECKS[words[6]],
        cond_val = must_tonumber(words[7]),
    }, self)
end

---@param registers table<string, integer>
---@return boolean executed, integer val
function Instruction:execute(registers)
    local cond_reg_val = registers[self.cond_reg] or 0
    local meet = false
    if self.cond_check == CHECKS.gt then
        meet = cond_reg_val > self.cond_val
    elseif self.cond_check == CHECKS.gte then
        meet = cond_reg_val >= self.cond_val
    elseif self.cond_check == CHECKS.lt then
        meet = cond_reg_val < self.cond_val
    elseif self.cond_check == CHECKS.lte then
        meet = cond_reg_val <= self.cond_val
    elseif self.cond_check == CHECKS.eq then
        meet = cond_reg_val == self.cond_val
    elseif self.cond_check == CHECKS.ne then
        meet = cond_reg_val ~= self.cond_val
    end

    if not meet then return false, 0 end

    local val = registers[self.modify_reg] or 0
    if self.action == 1 then
        registers[self.modify_reg] = val + self.amount
    else
        registers[self.modify_reg] = val - self.amount
    end

    return true, registers[self.modify_reg]
end

---@param input string
local function largest_after_execution(input)
    local registers = {}
    for line in input:gmatch('[^\r\n]+') do
        Instruction:new(line):execute(registers)
    end

    local largest = 0
    for _, v in pairs(registers) do
        largest = math.max(largest, v)
    end

    return largest
end

---@param input string
local function largest_during_execution(input)
    local registers = {}
    local largest = 0

    for line in input:gmatch('[^\r\n]+') do
        local executed, val = Instruction:new(line):execute(registers)
        if executed then
            largest = math.max(largest, val)
        end
    end

    return largest
end

local M = {}
M.Instruction = Instruction
M.largest_after_execution = largest_after_execution
M.largest_during_execution = largest_during_execution
return M

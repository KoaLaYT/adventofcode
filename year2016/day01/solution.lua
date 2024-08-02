---@alias Dir
---| 0 # North
---| 1 # East
---| 2 # South
---| 3 # West

---@class Human
---@field x integer
---@field y integer
---@field dir Dir
local Human = {}
Human.__index = Human

---@return Human
function Human:new()
    return setmetatable({
        x = 0,
        y = 0,
        dir = 0,
    }, self)
end

---@alias Turn
---| 1 # right
---| -1 # left

---@class Instruction
---@field turn Turn
---@field blocks integer

---@private
---@param instruction Instruction
---@param map table?
function Human:_walk(instruction, map)
    self.dir = (self.dir + instruction.turn) % 4

    local blocks = instruction.blocks
    if self.dir == 0 then
        return self:_walk_and_record(function() self.y = self.y + 1 end, blocks, map)
    elseif self.dir == 1 then
        return self:_walk_and_record(function() self.x = self.x + 1 end, blocks, map)
    elseif self.dir == 2 then
        return self:_walk_and_record(function() self.y = self.y - 1 end, blocks, map)
    elseif self.dir == 3 then
        return self:_walk_and_record(function() self.x = self.x - 1 end, blocks, map)
    end
end

---@private
---@param update fun(): nil
---@param blocks integer
---@param map table?
function Human:_walk_and_record(update, blocks, map)
    local found = false
    for _ = 1, blocks do
        update()
        if self:_record(map) then
            found = true
            break
        end
    end
    return found
end

---@private
---@param map table?
function Human:_record(map)
    if map ~= nil then
        local p = string.format('%d,%d', self.x, self.y)
        if map[p] == nil then
            map[p] = 1
        else
            return true
        end
    end
    return false
end

---@param instructions Instruction[]
---@param map table?
function Human:walks(instructions, map)
    for _, instruction in ipairs(instructions) do
        local found = self:_walk(instruction, map)
        if found then
            break
        end
    end
end

---@return integer
function Human:distance()
    return math.abs(self.x) + math.abs(self.y)
end

---@param s string
---@return Instruction[]
local function parse_instructions(s)
    local instructions = {}
    local h = require('libs.helper')

    while s:len() > 0 do
        ---@type Turn
        local turn
        if s:sub(1, 1) == 'L' then
            turn = -1
        else
            turn = 1
        end
        local blocks, i = h.parse_integer(s, 2)

        table.insert(instructions, { turn = turn, blocks = blocks, })
        s = s:sub(i + 2)
    end

    return instructions
end

local M = {}
M.Human = Human
M.parse_instructions = parse_instructions
return M

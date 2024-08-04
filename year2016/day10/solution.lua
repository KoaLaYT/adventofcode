---@class GiveInstruction
---@field target 'bot' | 'output'
---@field id integer

---@class Bot
---@field id string
---@field chips integer[]
---@field give_lo_to GiveInstruction
---@field give_hi_to GiveInstruction
local Bot = {}
Bot.__index = Bot

---@class Factory
---@field bots table<string, Bot>
---@field outputs table<string, integer>
local Factory = {}
Factory.__index = Factory

---@param id string
---@return Bot
function Bot:new(id)
    return setmetatable({
        id = id,
        chips = {},
    }, self)
end

---@return string
function Bot:__tostring()
    local c1, c2 = self.chips[1], self.chips[2]
    return string.format('bot %s, chips [%s,%s], low -> %s %s, high -> %s %s',
        self.id, tostring(c1), tostring(c2),
        self.give_lo_to.target, self.give_lo_to.id,
        self.give_hi_to.target, self.give_hi_to.id)
end

---@param factory Factory
---@return boolean processed
function Bot:try_process(factory)
    if #self.chips ~= 2 then return false end

    local lo = math.min(unpack(self.chips))
    self:_give(lo, self.give_lo_to, factory)

    local hi = math.max(unpack(self.chips))
    self:_give(hi, self.give_hi_to, factory)

    self.chips = {}
    return true
end

---@param chips integer[]
---@return boolean
function Bot:has_chips(chips)
    if #self.chips ~= #chips then return false end

    local a1, b1 = unpack(self.chips)
    local a2, b2 = unpack(chips)

    return (a1 == a2 and b1 == b2)
        or (a1 == b2 and b1 == a2)
end

---@private
---@param chip integer
---@param inst GiveInstruction
---@param factory Factory
function Bot:_give(chip, inst, factory)
    if inst.target == 'bot' then
        table.insert(factory.bots[inst.id].chips, chip)
    elseif inst.target == 'output' then
        factory.outputs[inst.id] = chip
    else
        error(string.format('unknown target: %s', inst.target))
    end
end

---@param line string
---@param bots table<string, Bot>
---@return boolean processed
local function _try_process_as_value_inst(line, bots)
    local chip, id = line:match('^value (%d+) goes to bot (%d+)$')
    if chip ~= nil and id ~= nil then
        if bots[id] == nil then
            bots[id] = Bot:new(id)
        end
        table.insert(bots[id].chips, assert(tonumber(chip)))
        return true
    end
    return false
end

---@param line string
---@param bots table<string, Bot>
---@return boolean processed
local function _try_process_as_give_inst(line, bots)
    local id, lo_target, lo_id, hi_target, hi_id =
        line:match('^bot (%d+) gives low to (%l+) (%d+) and high to (%l+) (%d+)$')
    if id ~= nil
        and (lo_target == 'bot' or lo_target == 'output')
        and lo_id ~= nil
        and (hi_target == 'bot' or hi_target == 'output')
        and hi_id ~= nil then
        if bots[id] == nil then
            bots[id] = Bot:new(id)
        end
        bots[id].give_lo_to = {
            target = lo_target,
            id = lo_id,
        }
        bots[id].give_hi_to = {
            target = hi_target,
            id = hi_id,
        }
        return true
    end
    return false
end

---@param instructions string
---@return Factory
function Factory:new(instructions)
    local processes = {
        _try_process_as_value_inst,
        _try_process_as_give_inst,
    }
    local bots = {}

    for line in instructions:gmatch('[^\r\n]+') do
        local processed = false

        for _, process in ipairs(processes) do
            processed = process(line, bots)
            if processed then break end
        end

        if not processed then
            error(string.format('unknown instruction: %s', line))
        end
    end

    return setmetatable({
        bots = bots,
        outputs = {},
    }, self)
end

---@param chips integer[]
---@return string
function Factory:find_chips(chips)
    while true do
        local processed = false
        for _, bot in pairs(self.bots) do
            if bot:has_chips(chips) then return bot.id end
            processed = bot:try_process(self)
            if processed then break end
        end

        if not processed then
            error('no such chips')
        end
    end
end

---@param output_ids string[]
---@return integer
function Factory:multiply_outputs(output_ids)
    while true do
        local output_processed = 0
        local value = 1
        for id, output in pairs(self.outputs) do
            for _, output_id in ipairs(output_ids) do
                if id == output_id then
                    output_processed = output_processed + 1
                    value = value * output
                end
            end
        end
        if output_processed == #output_ids then return value end

        local processed = false
        for _, bot in pairs(self.bots) do
            processed = bot:try_process(self)
            if processed then break end
        end

        if not processed then
            error('output can not fulfilled')
        end
    end
end

---@return string
function Factory:__tostring()
    local str = 'Factory:\n--Bots:'
    for _, bot in pairs(self.bots) do
        str = str .. '\n' .. tostring(bot)
    end
    str = str .. '\n--Ouputs:'
    for id, output in pairs(self.outputs) do
        str = str .. string.format('\n ouput %d: %d', id, output)
    end
    return str
end

local M = {}
M.Factory = Factory
return M

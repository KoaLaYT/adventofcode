---@class Keypad
---@field i integer
---@field j integer
local Keypad = {}
Keypad.__index = Keypad

---@return Keypad
function Keypad:new()
    return setmetatable({
        i = 1,
        j = 1,
    }, self)
end

---@param input string
---@return string
function Keypad:get_code(input)
    local code = ''
    for line in input:gmatch('[^\r\n]+') do
        code = code .. self:_get_one_code(line)
    end
    return code
end

local u = string.byte('U')
local d = string.byte('D')
local l = string.byte('L')
local r = string.byte('R')

---@private
---@param s string
---@return string
function Keypad:_get_one_code(s)
    for i = 1, #s do
        local c = s:byte(i)
        if c == u then
            self.i = math.max(0, self.i - 1)
        elseif c == d then
            self.i = math.min(2, self.i + 1)
        elseif c == l then
            self.j = math.max(0, self.j - 1)
        elseif c == r then
            self.j = math.min(2, self.j + 1)
        end
    end

    return string.format('%d', 1 + self.i * 3 + self.j)
end

---@class BathroomKeypad
---@field i integer
---@field j integer
local BathroomKeypad = {}
BathroomKeypad.__index = BathroomKeypad

local bathroom_keypad_design = {
    'XX1XX',
    'X234X',
    '56789',
    'XABCX',
    'XXDXX',
}
local x = string.byte('X')

---@return BathroomKeypad
function BathroomKeypad:new()
    return setmetatable({
        i = 3,
        j = 1,
    }, self)
end

---
---@param input string
---@return string
function BathroomKeypad:get_code(input)
    local code = ''
    for line in input:gmatch('[^\r\n]+') do
        code = code .. self:_get_one_code(line)
    end
    return code
end

---@private
---@param s string
---@return string
function BathroomKeypad:_get_one_code(s)
    for i = 1, #s do
        local c = s:byte(i)
        if c == u then
            self:_move(self.i - 1, self.j)
        elseif c == d then
            self:_move(self.i + 1, self.j)
        elseif c == l then
            self:_move(self.i, self.j - 1)
        elseif c == r then
            self:_move(self.i, self.j + 1)
        end
    end

    return bathroom_keypad_design[self.i]:sub(self.j, self.j)
end

---@private
---@param i integer
---@param j integer
function BathroomKeypad:_move(i, j)
    if i < 1 or i > 5 or j < 1 or j > 5 then
        return
    end

    if bathroom_keypad_design[i]:byte(j) == x then
        return
    end

    self.i = i
    self.j = j
end

local M = {}
M.Keypad = Keypad
M.BathroomKeypad = BathroomKeypad
return M

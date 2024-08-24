local DIR = {
    n = { 0, 1, },
    ne = { 1, 0.5, },
    se = { 1, -0.5, },
    s = { 0, -1, },
    sw = { -1, -0.5, },
    nw = { -1, 0.5, },
}

---@class Position
---@field x number
---@field y number
local Position = {}
Position.__index = Position

---@param x number
---@param y number
---@return Position
function Position:new(x, y)
    return setmetatable({ x = x, y = y, }, self)
end

---@param dir number[]
---@return Position
function Position:move(dir)
    self.x = self.x + dir[1]
    self.y = self.y + dir[2]
end

---@param dst Position
---@return integer
local function fewest_step_to(dst)
    local x = math.abs(dst.x)
    local y = math.abs(dst.y)

    if y * 2 >= x then
        return x + y - x * 0.5
    else
        return x
    end
end

---@param input string
---@return integer
local function step_away(input)
    local pos = Position:new(0, 0)

    for dir in input:gmatch('%l+') do
        pos:move(DIR[dir])
    end

    return fewest_step_to(pos)
end

---@param input string
---@return integer
local function furthest(input)
    local pos = Position:new(0, 0)
    local max = 0

    for dir in input:gmatch('%l+') do
        pos:move(DIR[dir])
        max = math.max(max, fewest_step_to(pos))
    end

    return max
end

local M = {}
M.step_away = step_away
M.furthest = furthest
return M

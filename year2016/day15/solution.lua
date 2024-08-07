---@class Disc
---@field cur_pos integer
---@field max_pos integer
local Disc = {}
Disc.__index = Disc

---@param cur integer
---@param max integer
---@return Disc
function Disc:new(cur, max)
    return setmetatable({ cur_pos = cur, max_pos = max, }, self)
end

---@param time integer
---@return integer
function Disc:pos_at(time)
    return (self.cur_pos + time) % self.max_pos
end

---@class Sculpture
---@field discs Disc[]
local Sculpture = {}
Sculpture.__index = Sculpture

---@param discs Disc[]
---@return Sculpture
function Sculpture:new(discs)
    return setmetatable({
        discs = discs,
    }, self)
end

---@return integer
function Sculpture:first_time_get_capsule()
    for time = 0, math.huge do
        local fall_through = true
        for i, disc in ipairs(self.discs) do
            local pos = disc:pos_at(time + i)
            if pos ~= 0 then
                fall_through = false
                break
            end
        end
        if fall_through then return time end
    end

    error('unreachable')
end

local M = {}
M.Disc = Disc
M.Sculpture = Sculpture
return M

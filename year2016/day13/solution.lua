local Queue = require('libs.queue')

---@param num integer
---@return integer # number of ones
local function count_bits(num)
    local ones = 0
    while num > 0 do
        if num % 2 == 1 then
            ones = ones + 1
        end
        num = math.floor(num / 2)
    end
    return ones
end

---@class Coordinate
---@field x integer
---@field y integer
local Coordinate = {}
Coordinate.__index = Coordinate

---@param x integer
---@param y integer
---@return Coordinate
function Coordinate:new(x, y)
    return setmetatable({ x = x, y = y, }, self)
end

---@return string
function Coordinate:__tostring()
    return string.format('%d,%d', self.x, self.y)
end

---@param fav_num integer
---@return boolean
function Coordinate:is_open_space(fav_num)
    local v = self.x * self.x + 3 * self.x + 2 * self.x * self.y + self.y + self.y * self.y
    v = v + fav_num
    return count_bits(v) % 2 == 0
end

---@return boolean
function Coordinate:in_range()
    return self.x >= 0 and self.y >= 0
end

---@param s Coordinate
---@param i integer
local function _coordinate_iter(s, i)
    if i > 3 then return nil, nil end

    if i == 0 then
        return i + 1, Coordinate:new(s.x, s.y - 1)
    elseif i == 1 then
        return i + 1, Coordinate:new(s.x + 1, s.y)
    elseif i == 2 then
        return i + 1, Coordinate:new(s.x, s.y + 1)
    elseif i == 3 then
        return i + 1, Coordinate:new(s.x - 1, s.y)
    end
end

function Coordinate:neighor()
    return _coordinate_iter, self, 0
end

---@param x integer
---@param y integer
---@param fav_num integer
---@return integer
local function shortest_route_to(x, y, fav_num)
    local steps = 0
    local queue = Queue:new()
    local origin = Coordinate:new(1, 1)
    queue:enqueue(origin)
    local visited = { [tostring(origin)] = true, }

    while queue:len() > 0 do
        for _ = 1, queue:len() do
            local coordinate = queue:dequeue()
            if coordinate.x == x and coordinate.y == y then
                return steps
            end

            for _, neighor in coordinate:neighor() do
                local key = tostring(neighor)
                if neighor:in_range() and not visited[key] then
                    visited[key] = true
                    if neighor:is_open_space(fav_num) then
                        queue:enqueue(neighor)
                    end
                end
            end
        end
        steps = steps + 1
    end

    error(string.format('can not reach (%d,%d)', x, y))
end

---@param max_steps integer
---@param fav_num integer
local function visited_locations_by(max_steps, fav_num)
    local steps = 0
    local queue = Queue:new()
    local origin = Coordinate:new(1, 1)
    queue:enqueue(origin)
    local visited = { [tostring(origin)] = true, }
    local locations = 0

    while queue:len() > 0 do
        for _ = 1, queue:len() do
            local coordinate = queue:dequeue()
            for _, neighor in coordinate:neighor() do
                local key = tostring(neighor)
                if neighor:in_range() and not visited[key] then
                    visited[key] = true
                    if neighor:is_open_space(fav_num) then
                        queue:enqueue(neighor)
                        locations = locations + 1
                    end
                end
            end
        end
        steps = steps + 1
        if steps == max_steps then break end
    end

    return locations + queue:len()
end

local M = {}
M.count_bits = count_bits
M.shortest_route_to = shortest_route_to
M.visited_locations_by = visited_locations_by
return M

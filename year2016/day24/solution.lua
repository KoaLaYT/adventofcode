local Queue = require('libs.queue')

---@param a integer[]
---@param n integer?
local function _permgen(a, n)
    n = n or #a
    if n <= 1 then
        coroutine.yield(a)
    else
        for i = 1, n do
            a[n], a[i] = a[i], a[n]
            _permgen(a, n - 1)
            a[n], a[i] = a[i], a[n]
        end
    end
end

---@param a integer[]
local function _permutations(a)
    local co = coroutine.create(function() _permgen(a) end)
    return function()
        local _, v = coroutine.resume(co)
        return v
    end
end

---@param routes table<string, integer>
---@param points integer
local function _shortest_route(routes, points)
    local a = {}
    for i = 1, points do
        a[i] = i
    end

    local fewest = math.huge
    for p in _permutations(a) do
        local steps = 0
        for i = 1, #p do
            local key = ''
            if i == 1 then
                key = string.format('0-%d', p[i])
            else
                key = string.format('%d-%d', p[i - 1], p[i])
            end
            steps = steps + routes[key]
        end
        fewest = math.min(fewest, steps)
    end

    return fewest
end

---@param routes table<string, integer>
---@param points integer
local function _shortest_route_v2(routes, points)
    local a = {}
    for i = 1, points do
        a[i] = i
    end

    local fewest = math.huge
    for p in _permutations(a) do
        local steps = 0
        for i = 1, #p do
            local key = ''
            if i == 1 then
                key = string.format('0-%d', p[i])
            else
                key = string.format('%d-%d', p[i - 1], p[i])
            end
            steps = steps + routes[key]
        end
        steps = steps + routes[string.format('%d-0', p[#p])]
        fewest = math.min(fewest, steps)
    end

    return fewest
end

local wall_byte = string.byte('#')
local open_byte = string.byte('.')

---@class Location
---@field val integer
---@field row integer
---@field col integer
local Location = {}
Location.__index = Location

---@param val integer
---@param row integer
---@param col integer
---@return Location
function Location:new(val, row, col)
    return setmetatable({ val = val, row = row, col = col, }, self)
end

---@return string
function Location:__tostring()
    return string.format('%d,%d', self.row, self.col)
end

---@param map integer[][]
---@param loc Location
---@return Location[]
local function _next_locations(map, loc)
    local next = {}

    local row, col = loc.row, loc.col
    local width, height = #map[1], #map

    if row - 1 >= 1 and map[row - 1][col] ~= wall_byte then
        table.insert(next, Location:new(map[row - 1][col], row - 1, col))
    end
    if col + 1 <= width and map[row][col + 1] ~= wall_byte then
        table.insert(next, Location:new(map[row][col + 1], row, col + 1))
    end
    if row + 1 <= height and map[row + 1][col] ~= wall_byte then
        table.insert(next, Location:new(map[row + 1][col], row + 1, col))
    end
    if col - 1 >= 1 and map[row][col - 1] ~= wall_byte then
        table.insert(next, Location:new(map[row][col - 1], row, col - 1))
    end

    return next
end

---@param routes table<string, integer>
---@param map integer[][]
---@param start Location
local function _find_route(routes, map, start)
    local queue = Queue:new()
    queue:enqueue(start)
    local visited = { [tostring(start)] = true, }
    local steps = 0

    while queue:len() > 0 do
        for _ = 1, queue:len() do
            ---@type Location
            local loc = queue:dequeue()
            if loc.val ~= open_byte then
                routes[string.format('%d-%d', string.char(start.val), string.char(loc.val))] = steps
            end
            for _, next in ipairs(_next_locations(map, loc)) do
                if not visited[tostring(next)] then
                    visited[tostring(next)] = true
                    queue:enqueue(next)
                end
            end
        end
        steps = steps + 1
    end
end

---@param input string
---@return integer[][], Location[]
local function _parse_map(input)
    local map = {}
    local points = {}

    local i = 1
    for line in input:gmatch('[^\r\n]+') do
        local row = {}
        for j = 1, #line do
            row[j] = line:byte(j)
            if row[j] ~= wall_byte and row[j] ~= open_byte then
                table.insert(points, Location:new(row[j], i, j))
            end
        end
        map[i] = row
        i = i + 1
    end

    return map, points
end

---@param input string
---@param part2 boolean?
---@return integer
local function shortest_route(input, part2)
    local map, points = _parse_map(input)
    local routes = {}

    for _, start in ipairs(points) do
        _find_route(routes, map, start)
    end

    if part2 then
        return _shortest_route_v2(routes, #points - 1)
    else
        return _shortest_route(routes, #points - 1)
    end
end

local M = {}
M._shortest_route = _shortest_route
M._shortest_route_v2 = _shortest_route_v2
M.shortest_route = shortest_route
return M

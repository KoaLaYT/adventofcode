local Queue = require('libs.queue')
local md5 = require('libs.openssl_md5')

local a = string.byte('a')
local f = string.byte('f')

---@param b integer
---@return boolean
local function _is_open(b)
    return b > a and b <= f
end

---@class Room
---@field x integer
---@field y integer
---@field path string
local Room = {}
Room.__index = Room

---@return Room
function Room:new(x, y, path)
    return setmetatable({ x = x, y = y, path = path, }, self)
end

---@return Room
function Room:origin()
    return setmetatable({ x = 1, y = 1, path = '', }, self)
end

---@param passcode string
---@return Room[]
function Room:next_rooms(passcode)
    local next = {}

    local hash = md5(string.format('%s%s', passcode, self.path))

    local up = _is_open(hash:byte(1))
    local down = _is_open(hash:byte(2))
    local left = _is_open(hash:byte(3))
    local right = _is_open(hash:byte(4))

    if up and self.y > 1 then
        next[#next + 1] = Room:new(self.x, self.y - 1, self.path .. 'U')
    end

    if down and self.y < 4 then
        next[#next + 1] = Room:new(self.x, self.y + 1, self.path .. 'D')
    end

    if left and self.x > 1 then
        next[#next + 1] = Room:new(self.x - 1, self.y, self.path .. 'L')
    end

    if right and self.x < 4 then
        next[#next + 1] = Room:new(self.x + 1, self.y, self.path .. 'R')
    end

    return next
end

---@param passcode string
---@return string
local function shortest_path(passcode)
    local queue = Queue:new()
    queue:enqueue(Room:origin())

    while queue:len() > 0 do
        ---@type Room
        local room = queue:dequeue()
        if room.x == 4 and room.y == 4 then
            return room.path
        end

        for _, next_room in ipairs(room:next_rooms(passcode)) do
            queue:enqueue(next_room)
        end
    end

    error('can not reach vault')
end

---@param passcode string
---@return integer
local function longest_path(passcode)
    local queue = Queue:new()
    queue:enqueue(Room:origin())
    local longest = 0

    while queue:len() > 0 do
        ---@type Room
        local room = queue:dequeue()
        if room.x == 4 and room.y == 4 then
            longest = math.max(longest, #room.path)
        else
            for _, next_room in ipairs(room:next_rooms(passcode)) do
                queue:enqueue(next_room)
            end
        end
    end

    return longest
end

local M = {}
M.shortest_path = shortest_path
M.longest_path = longest_path
return M

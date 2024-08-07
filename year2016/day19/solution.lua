local Queue = require('libs.queue')

---@class Elf
---@field id integer
---@field next Elf
local Elf = {}
Elf.__index = Elf

---@param id integer
---@return Elf
function Elf:new(id)
    return setmetatable({ id = id, next = nil, }, self)
end

---@param size integer
local function _init_circle(size)
    ---@type Elf, Elf, Elf
    local head, tail, prev
    for i = 1, size do
        local elf = Elf:new(i)
        if i == 1 then
            head = elf
        end

        if i == size then
            tail = elf
        end

        if prev ~= nil then
            prev.next = elf
        end

        prev = elf
    end
    tail.next = head
    return head
end

---@param size integer
---@return integer id
local function get_all_present(size)
    local cur = _init_circle(size)
    while cur.next ~= cur do
        cur.next = cur.next.next
        cur = cur.next
    end
    return cur.id
end

local function _init_circle_v2(size)
    local q1, q2 = Queue:new(), Queue:new()
    local mid = math.floor(size / 2)
    for i = 1, mid do
        q1:enqueue(i)
    end
    for i = mid + 1, size do
        q2:enqueue(i)
    end
    return q1, q2
end

---@param size integer
---@return integer id
local function get_all_present_v2(size)
    local q1, q2 = _init_circle_v2(size)

    while q1:len() > 0 do
        q2:dequeue() -- delete
        q2:enqueue(q1:dequeue())

        if q2:len() - q1:len() > 1 then
            q1:enqueue(q2:dequeue())
        end
    end

    return q2:dequeue()
end

local M = {}
M.get_all_present = get_all_present
M.get_all_present_v2 = get_all_present_v2
return M

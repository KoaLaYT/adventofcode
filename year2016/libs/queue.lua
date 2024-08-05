---@class Queue
---@field list any[]
---@field head integer
---@field tail integer
local Queue = {}
Queue.__index = Queue

---@return Queue
function Queue:new()
    return setmetatable({
        list = {},
        head = 0,
        tail = 0,
    }, self)
end

---@param v any
function Queue:enqueue(v)
    self.list[self.tail] = v
    self.tail = self.tail + 1
end

---@return any
function Queue:dequeue()
    local v = self.list[self.head]
    self.list[self.head] = nil
    self.head = self.head + 1
    return v
end

---@return integer
function Queue:len()
    return self.tail - self.head
end

return Queue

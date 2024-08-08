---@class Node
---@field x integer
---@field y integer
---@field size integer
---@field used integer
---@field avail integer
local Node = {}
Node.__index = Node

---@param s string
---@return integer
local function _must_tonumber(s)
    return assert(tonumber(s),
        string.format('%s tonumber failed', s))
end

---@param s string
---@return Node
function Node:new(s)
    local x, y, size, used, avail = s:match('^/dev/grid/node%-x(%d+)%-y(%d+)%s+(%d+)T%s+(%d+)T%s+(%d+)T')
    return setmetatable({
        x = _must_tonumber(x),
        y = _must_tonumber(y),
        size = _must_tonumber(size),
        used = _must_tonumber(used),
        avail = _must_tonumber(avail),
    }, self)
end

---@return string
function Node:__tostring()
    return string.format('(%d-%d)(%d/%d)',
        self.x, self.y, self.used, self.size)
end

---@param input string
---@return integer
local function viable_pairs(input)
    local nodes = {}
    for line in input:gmatch('[^\r\n]+') do
        table.insert(nodes, Node:new(line))
    end

    local checked = {}
    local viable = 0

    for i = 1, #nodes do
        for j = 1, #nodes do
            local a = nodes[i]
            local b = nodes[j]
            local a_key = a:key()
            local b_key = b:key()
            local key = string.format('%s,%s', a_key, b_key)

            if not checked[key] then
                checked[key] = true
                if a_key ~= b.key and a.used > 0 and a.used <= b.avail then
                    viable = viable + 1
                end
            end
        end
    end

    return viable
end

---@param nodes Node[]
---@param empty_node Node
local function _print_grid(nodes, empty_node)
    local rows = {}
    for _, node in ipairs(nodes) do
        local x, y = node.x, node.y + 1
        if rows[y] == nil then rows[y] = string.format('%2d: ', y - 1) end
        if x > 0 then
            rows[y] = rows[y] .. ' '
        end
        if node.used == 0 then
            rows[y] = rows[y] .. '_'
        elseif node.used <= 92 then
            rows[y] = rows[y] .. '.'
        else
            rows[y] = rows[y] .. '#'
        end
    end
    print(table.concat(rows, '\n'))
end

---@param input string
---@return integer
local function fewest_step(input)
    local nodes = {}
    local empty_node
    local max_x = 0
    for line in input:gmatch('[^\r\n]+') do
        local node = Node:new(line)
        table.insert(nodes, node)
        if node.used == 0 then empty_node = node end
        max_x = math.max(max_x, node.x)
    end
    _print_grid(nodes, empty_node)
    -- manually calculated by watching printed grid
    return empty_node.x + empty_node.y + max_x + (max_x - 1) * 5
end

local M = {}
M.Node = Node
M.viable_pairs = viable_pairs
M.fewest_step = fewest_step
return M

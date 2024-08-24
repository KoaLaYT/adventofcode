local Queue = require('libs.queue')

---@param s string
---@return integer
local function must_tonumber(s)
    return assert(tonumber(s))
end

---@param input string
---@return table<integer, integer[]>, integer
local function parse(input)
    local map = {}
    local max_id = 0
    for line in input:gmatch('[^\r\n]+') do
        local is_first = true
        local id;
        for num in line:gmatch('%d+') do
            if is_first then
                id = must_tonumber(num)
                map[id] = {}
                max_id = id
                is_first = false
            else
                table.insert(map[id], #map[id] + 1, must_tonumber(num))
            end
        end
    end
    return map, max_id
end

---@param id integer
---@param map table<integer, integer[]>
local function can_contact_zero(id, map)
    local queue = Queue:new()
    queue:enqueue(id)
    local visited = { [id] = true, }

    while queue:len() > 0 do
        local p = queue:dequeue()
        if p == 0 then
            return true
        end
        for _, pp in ipairs(map[p]) do
            if not visited[pp] then
                visited[pp] = true
                queue:enqueue(pp)
            end
        end
    end

    return false
end

---@param input string
---@return integer
local function contact_zero_programs(input)
    local map, max_id = parse(input)
    local count = 0
    for id = 0, max_id do
        if can_contact_zero(id, map) then
            count = count + 1
        end
    end
    return count
end

---@param src integer
---@param map table<integer, integer[]>
---@param walked table<integer, boolean>
local function walk(src, map, walked)
    local queue = Queue:new()
    queue:enqueue(src)
    local visited = { [src] = true, }
    walked[src] = true

    while queue:len() > 0 do
        local p = queue:dequeue()
        for _, pp in ipairs(map[p]) do
            if not visited[pp] then
                visited[pp] = true
                walked[pp] = true
                queue:enqueue(pp)
            end
        end
    end
end

---@param input string
---@return integer
local function groups(input)
    local map, max_id = parse(input)
    local walked = {}
    local groups = 0
    for id = 0, max_id do
        if not walked[id] then
            groups = groups + 1
            walk(id, map, walked)
        end
    end
    return groups
end

local M = {}
M.parse = parse
M.contact_zero_programs = contact_zero_programs
M.groups = groups
return M

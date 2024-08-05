local Queue = require('libs.queue')

---@class Floor
---@field microchips string[]
---@field generators string[]

---@class State
---@field floors Floor[]
---@field current_floor integer
---@field steps integer
local State = {}
State.__index = State

---@param floors Floor[]
---@return State
function State:new(floors)
    return setmetatable({
        floors = floors,
        current_floor = 1,
        steps = 0,
    }, self)
end

---@return boolean
function State:all_on_top()
    if self.current_floor ~= #self.floors then return false end
    for i = 1, #self.floors - 1 do
        if #self.floors[i].microchips > 0
            or #self.floors[i].generators > 0 then
            return false
        end
    end
    return true
end

---@return Floor
function State:_curr_floor()
    return self.floors[self.current_floor]
end

function State:_below_all_empty()
    local is_below_all_empty = true
    for i = 1, self.current_floor - 1 do
        if #self.floors[i].generators > 0
            or #self.floors[i].microchips > 0 then
            is_below_all_empty = false
            break
        end
    end
    return is_below_all_empty
end

-- interchangeable key, example:
--   on floor 1, there is no difference between (HM,HG) and (LM,LG)
--   they all count as 1M,1G
---@return string
function State:key()
    local floor_strs = {}
    for i = #self.floors, 1, -1 do
        local floor_str = ''
        if i == self.current_floor then
            floor_str = 'E'
        else
            floor_str = ' '
        end
        floor_str = floor_str .. string.format('%d', i)
        local floor = self.floors[i]
        floor_str = floor_str .. string.format(',%dM', #floor.microchips)
        floor_str = floor_str .. string.format(',%dG', #floor.generators)
        table.insert(floor_strs, floor_str)
    end
    return table.concat(floor_strs, '\n')
end

---@param floor_dir integer # 0 up 1 down
---@return State
function State:copy(floor_dir)
    local floors = {}
    for i = 1, #self.floors do
        floors[i] = {
            microchips = {},
            generators = {},
        }
        for j, m in ipairs(self.floors[i].microchips) do
            floors[i].microchips[j] = m
        end
        for j, g in ipairs(self.floors[i].generators) do
            floors[i].generators[j] = g
        end
    end
    local copy = State:new(floors)
    copy.steps = self.steps + 1

    if floor_dir == 0 then
        copy.current_floor = self.current_floor + 1
    elseif floor_dir == 1 then
        copy.current_floor = self.current_floor - 1
    end

    if copy.current_floor < 1 or copy.current_floor > #copy.floors then
        error('bad copy')
    end

    return copy
end

---@class StateIter
---@field origin_state State
---@field floor_i integer -- 0 up, 1 down
---@field one_i integer
---@field two_i integer
---@field two_j integer
---@field can_move_two boolean
---@field can_move_one boolean

---@param next State
---@param origin State
---@param idx integer
local function _do_move(next, origin, idx)
    local item_type = 'microchips'
    local origin_curr_floor = origin:_curr_floor()
    local next_curr_floor = next:_curr_floor()
    local next_origin_floor = next.floors[origin.current_floor]

    if idx > #origin_curr_floor.microchips then
        idx = idx - #origin_curr_floor.microchips
        item_type = 'generators'
    end

    local item = origin_curr_floor[item_type][idx]
    table.insert(next_curr_floor[item_type], 1, item)

    local i = 1
    while i <= #next_origin_floor[item_type] do
        if next_origin_floor[item_type][i] == item then
            break
        end
        i = i + 1
    end
    table.remove(next_origin_floor[item_type], i)
end

---@param s StateIter
---@return State?
local function _state_iter_one(s)
    -- top floor cannot go up
    if s.floor_i == 0 and s.origin_state.current_floor == #s.origin_state.floors then
        return nil
    end
    -- bottom floor cannot go down
    if s.floor_i == 1 and s.origin_state.current_floor == 1 then
        return nil
    end

    local current_floor = s.origin_state.floors[s.origin_state.current_floor]
    -- carry one all itered
    if s.one_i > #current_floor.microchips + #current_floor.generators then
        return nil
    end

    local copy = s.origin_state:copy(s.floor_i)
    _do_move(copy, s.origin_state, s.one_i)
    s.one_i = s.one_i + 1
    return copy
end

---@param s StateIter
---@return State?
local function _state_iter_two(s)
    -- top floor cannot go up
    if s.floor_i == 0 and s.origin_state.current_floor == #s.origin_state.floors then
        return nil
    end
    -- bottom floor cannot go down
    if s.floor_i == 1 and s.origin_state.current_floor == 1 then
        return nil
    end

    local current_floor = s.origin_state.floors[s.origin_state.current_floor]
    -- carry two all itered
    if s.two_i > #current_floor.microchips + #current_floor.generators then
        return nil
    end

    if s.two_j > #current_floor.microchips + #current_floor.generators then
        s.two_i = s.two_i + 1
        s.two_j = s.two_i + 1
        return _state_iter_two(s)
    end

    local copy = s.origin_state:copy(s.floor_i)
    _do_move(copy, s.origin_state, s.two_i)
    _do_move(copy, s.origin_state, s.two_j)
    s.two_j = s.two_j + 1
    return copy
end

---@param s StateIter
---@return State?
local function _state_iter(s)
    if s.floor_i == 2 then return nil end

    -- below all empty
    -- don't bother moving things back down
    if s.floor_i == 1 and s.origin_state:_below_all_empty() then
        return nil
    end

    -- 1. if we can move two items up
    --    don't bother try one
    -- 2. if we can move one items down
    --    don't bother try two
    local next_state = nil
    if s.floor_i == 0 then
        next_state = _state_iter_two(s)
        if next_state ~= nil and not s.can_move_two and next_state:is_valid() then
            s.can_move_two = true
        end
        if next_state == nil and not s.can_move_two then
            next_state = _state_iter_one(s)
        end
    end

    if s.floor_i == 1 then
        next_state = _state_iter_one(s)
        if next_state ~= nil and not s.can_move_one and next_state:is_valid() then
            s.can_move_one = true
        end
        if next_state == nil and not s.can_move_one then
            next_state = _state_iter_two(s)
        end
    end

    -- if not using the above optimization (5x slower)
    -- local next_state = _state_iter_one(s) or _state_iter_two(s)

    if next_state ~= nil then
        return next_state
    end

    s.floor_i = s.floor_i + 1
    s.one_i = 1
    s.two_i = 1
    s.two_j = 2
    return _state_iter(s)
end

function State:iter()
    return _state_iter,
        {
            origin_state = self,
            floor_i = 0,
            one_i = 1,
            two_i = 1,
            two_j = 2,
            can_move_one = false,
            can_move_two = false,
        },
        nil
end

---@return boolean
function State:is_valid()
    local floor = self:_curr_floor()

    if #floor.generators < 1 then return true end

    for _, m in ipairs(floor.microchips) do
        local match = false
        for _, g in ipairs(floor.generators) do
            if m == g then
                match = true
                break
            end
        end
        if not match then return false end
    end

    return true
end

---@param init_state State
---@return integer
local function min_steps(init_state)
    local states_queue = Queue:new()
    states_queue:enqueue(init_state)
    local tried_states = { [init_state:key()] = true, }
    local min = math.huge

    while states_queue:len() > 0 do
        local state = states_queue:dequeue()
        if state:all_on_top() then
            min = math.min(min, state.steps)
            break
        elseif state.steps < min - 1 then
            for next_state in state:iter() do
                local key = next_state:key()
                if not tried_states[key] and next_state:is_valid() then
                    tried_states[key] = true
                    states_queue:enqueue(next_state)
                end
            end
        end
    end

    return min
end

local M = {}
M.State = State
M.min_steps = min_steps
return M

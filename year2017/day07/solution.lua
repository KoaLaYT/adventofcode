---@param s string
---@return integer
local function must_tonumber(s)
    return assert(tonumber(s))
end

---@param row string
---@return string name, integer weight, string[] aboves
local function parse(row)
    do
        local name, weight = row:match('^(%l+) %((%d+)%)$')
        if name ~= nil and weight ~= nil then
            return name, must_tonumber(weight), {}
        end
    end

    do
        local name, weight, raw_aboves = row:match('^(%l+) %((%d+)%) %-> (.+)$')
        if name ~= nil and weight ~= nil and raw_aboves ~= nil then
            local aboves = {}
            for above in raw_aboves:gmatch('%l+') do
                table.insert(aboves, above)
            end
            return name, must_tonumber(weight), aboves
        end
    end

    error(string.format('Can not parse %s', row))
end

---@param input string
---@return table<string, string> # map: program -> program below it
local function parse_structure(input)
    local map = {}
    for row in input:gmatch('[^\r\n]+') do
        local name, _, aboves = parse(row)
        for _, above in ipairs(aboves) do
            map[above] = name
        end
    end
    return map
end

---@param map table<string, string>
---@return string
local function _find_bottom(map)
    local key = pairs(map)(map)

    while true do
        local below = map[key]
        if below == nil then
            return key
        else
            key = below
        end
    end
end

---@param input string
---@return string
local function find_bottom(input)
    local map = parse_structure(input)
    return _find_bottom(map)
end

---@param input string
---@return table<string,string>, table<string,integer>, table<string,string[]>
local function parse_structure_v2(input)
    local below_map = {}
    local weights = {}
    local upper_map = {}
    for row in input:gmatch('[^\r\n]+') do
        local name, weight, aboves = parse(row)
        weights[name] = weight
        for _, above in ipairs(aboves) do
            below_map[above] = name
        end
        if #aboves > 0 then
            upper_map[name] = aboves
        end
    end
    return below_map, weights, upper_map
end

---@param weights table<string,integer>
---@param upper_map table<string,string[]>
---@param name string
---@param right_weight integer
---@return boolean is_balance, integer total_weight,integer right_weight
local function _find_inbalance(
    weights,
    upper_map,
    name,
    right_weight)
    local uppers = upper_map[name]
    if uppers == nil then
        return true, weights[name], right_weight
    end

    local all_weight = 0
    local weight_map = {}
    for _, upper in ipairs(uppers) do
        local is_balance, total_weight, right_weight_ =
            _find_inbalance(weights, upper_map, upper, right_weight)
        if not is_balance then
            return false, 0, right_weight_
        end
        all_weight = all_weight + total_weight
        if weight_map[tostring(total_weight)] == nil then
            weight_map[tostring(total_weight)] = {}
        end
        table.insert(weight_map[tostring(total_weight)], upper)
    end

    local size = 0
    for _ in pairs(weight_map) do
        size = size + 1
    end

    if size == 1 then
        return true, all_weight + weights[name], right_weight
    end

    if size > 2 then
        error('more than one program has wrong weight')
    end

    ---@type string
    local inbalance_program
    ---@type integer
    local balance_weight
    ---@type integer
    local inbalance_weight
    for k, v in pairs(weight_map) do
        if #v == 1 then
            inbalance_program = v[1]
            inbalance_weight = must_tonumber(k)
        else
            balance_weight = must_tonumber(k)
        end
    end

    return false, 0, weights[inbalance_program] + balance_weight - inbalance_weight
end

---@param input string
---@return integer
local function find_inbalance(input)
    local below_map, weights, upper_map = parse_structure_v2(input)
    local bottom = _find_bottom(below_map)
    local _, _, right_weight = _find_inbalance(weights, upper_map, bottom, -1)
    return right_weight
end

local M = {}
M.parse = parse
M.find_bottom = find_bottom
M.find_inbalance = find_inbalance
return M

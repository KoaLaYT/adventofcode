---@class IpRange
---@field from integer
---@field to integer
local IpRange = {}
IpRange.__index = IpRange

---@return string
function IpRange:__tostring()
    return string.format('%d-%d', self.from, self.to)
end

---@param from integer
---@param to integer
---@return IpRange
function IpRange:new(from, to)
    return setmetatable({ from = from, to = to, }, self)
end

---@return integer
function IpRange:len()
    return self.to - self.from + 1
end

---@param other IpRange?
---@return boolean
function IpRange:intersect(other)
    if other == nil then return false end

    if self.to < other.from - 1 then
        return false
    end

    if self.from > other.to + 1 then
        return false
    end

    return true
end

--- call must ensure they are intersects
---@param other IpRange
---@return IpRange
function IpRange:merge(other)
    return IpRange:new(math.min(self.from, other.from), math.max(self.to, other.to))
end

---@param s string
---@return IpRange
local function _parse_range(s)
    local from, to = s:match('(%d+)-(%d+)')
    if from == nil or to == nil then
        error(string.format('bad range: %s', s))
    end
    return IpRange:new(assert(tonumber(from)), assert(tonumber(to)))
end

---@param ranges IpRange[]
local function _merge_range(ranges)
    table.sort(ranges, function(r1, r2)
        return r1.from < r2.from
    end)

    local k, i, j = 1, 1, 2
    local merged = 0
    while i <= #ranges do
        if ranges[i]:intersect(ranges[j]) then
            ranges[i] = ranges[i]:merge(ranges[j])
            merged = merged + 1
            j = j + 1
        else
            ranges[k] = ranges[i]
            i = j
            j = i + 1
            k = k + 1
        end
    end

    while k <= #ranges do
        ranges[k] = nil
        k = k + 1
    end
end

---@param input string
---@return integer
local function lowest_allowed_ip(input)
    local blacklists = {}

    for line in input:gmatch('[^\r\n]+') do
        local blacklist = _parse_range(line)
        table.insert(blacklists, blacklist)
    end

    _merge_range(blacklists)

    local lowest = 0
    for _, b in ipairs(blacklists) do
        if lowest < b.from then
            break
        else
            lowest = b.to + 1
        end
    end

    return lowest
end

---@param input string
---@param max integer
---@return integer
local function total_allowed_ips(input, max)
    local blacklists = {}

    for line in input:gmatch('[^\r\n]+') do
        local blacklist = _parse_range(line)
        table.insert(blacklists, blacklist)
    end

    _merge_range(blacklists)

    local allowed = max
    for _, b in ipairs(blacklists) do
        allowed = allowed - b:len()
    end

    return allowed
end

local M = {}
M.IpRange = IpRange
M.lowest_allowed_ip = lowest_allowed_ip
M.total_allowed_ips = total_allowed_ips
return M

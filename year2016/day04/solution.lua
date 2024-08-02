local h = require('libs.helper')

---@param input string
---@return string name,integer room_id,string checksum
local function _split_row(input)
    local name, room_id, checksum = input:match('([a-z%-]+)%-([0-9]+)%[([a-z]+)%]')
    room_id = h.parse_integer(room_id, 1)
    return name, room_id, checksum
end

---@param name string
---@return string
local function _order_letters(name)
    name = name:gsub('%-', '')
    local count = {}
    for i = 1, #name do
        local b = name:byte(i)
        if count[b] == nil then
            count[b] = 0
        end
        count[b] = count[b] + 1
    end

    local ordered = {}
    for k in pairs(count) do
        table.insert(ordered, #ordered + 1, k)
    end

    table.sort(ordered, function(a, b)
        if count[a] > count[b] then
            return true
        elseif count[a] == count[b] then
            return a < b
        else
            return false
        end
    end)

    return string.char(ordered[1], ordered[2], ordered[3], ordered[4], ordered[5])
end

---@param input string
---@return boolean is_real, integer room_id
local function _is_real_room(input)
    local name, room_id, checksum = _split_row(input)
    local ordered = _order_letters(name)
    return ordered == checksum, room_id
end

---@param input string
---@return integer
local function sum_real_room_ids(input)
    local result = 0
    for line in input:gmatch('[^\r\n]+') do
        local is_real, room_id = _is_real_room(line)
        if is_real then
            result = result + room_id
        end
    end
    return result
end

local dash = string.byte('-')
local a = string.byte('a')

---@param encrypted string
---@param rotate integer
---@return string
local function _decrypt_name(encrypted, rotate)
    rotate = rotate % 26

    local result = ''
    for i = 1, #encrypted do
        local c = encrypted:byte(i)
        if c == dash then
            result = result .. ' '
        else
            result = result .. string.char(a + (c - a + rotate) % 26)
        end
    end

    return result
end

---@param input string
---@param room_name string
---@return integer room_id, string decrypted_name, string rawdata
local function find_room(input, room_name)
    for line in input:gmatch('[^\r\n]+') do
        local name, room_id, checksum = _split_row(line)
        local ordered = _order_letters(name)
        if ordered == checksum then
            local decrypted = _decrypt_name(name, room_id)
            if decrypted:match(room_name) then
                return room_id, decrypted, line
            end
        end
    end
    error('no such room')
end

local M = {}
M._split_row = _split_row
M._count_letters = _order_letters
M._is_real_room = _is_real_room
M._decrypt_name = _decrypt_name
M.sum_real_room_ids = sum_real_room_ids
M.find_room = find_room
return M

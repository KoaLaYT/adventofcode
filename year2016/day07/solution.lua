---@param input string
---@return boolean
local function _has_ABBA(input)
    if #input < 4 then return false end
    for i = 1, #input - 3 do
        local a = input:byte(i)
        local b = input:byte(i + 1)
        local c = input:byte(i + 2)
        local d = input:byte(i + 3)
        if a ~= b and a == d and b == c then
            return true
        end
    end
    return false
end

---@param input string
---@return string[]
local function _fetch_ABA(input)
    local result = {}
    if #input < 3 then return result end
    for i = 1, #input - 2 do
        local a = input:byte(i)
        local b = input:byte(i + 1)
        local c = input:byte(i + 2)
        if a ~= b and a == c then
            table.insert(result, string.char(a, b, c))
        end
    end
    return result
end

---@param aba string
---@param bab string
---@return boolean
local function _is_ABA_match(aba, bab)
    if #aba ~= 3 and #aba ~= #bab then return false end

    return aba:byte(1) == bab:byte(2)
        and aba:byte(2) == bab:byte(1)
end

local left_bracket = string.byte('[')
local right_bracket = string.byte(']')

---@class Subnet
---@field in_bracket boolean
---@field str string

---@param ipv7 string
---@param idx integer
---@return integer?, Subnet?
local function _iter_ipv7(ipv7, idx)
    if idx > #ipv7 then return nil, nil end

    local first_byte = ipv7:byte(idx)
    local target_byte = left_bracket
    local in_bracket = false

    if first_byte == left_bracket then
        in_bracket = true
        target_byte = right_bracket
        idx = idx + 1
    end

    for i = idx, #ipv7 do
        local b = ipv7:byte(i)
        if b == target_byte then
            return in_bracket and i + 1 or i,
                { in_bracket = in_bracket, str = ipv7:sub(idx, i - 1), }
        end
    end

    if in_bracket then
        error('no matching ]')
    end

    return #ipv7 + 1, { in_bracket = false, str = ipv7:sub(idx), }
end

---@param ipv7 string
---@return boolean
local function support_tls(ipv7)
    local outside_has_ABBA = false
    local inside_has_ABBA = false

    for _, subnet in _iter_ipv7, ipv7, 1 do
        if inside_has_ABBA then return false end
        local has_ABBA = _has_ABBA(subnet.str)
        if subnet.in_bracket then
            inside_has_ABBA = has_ABBA
        else
            outside_has_ABBA = outside_has_ABBA or has_ABBA
        end
    end

    return outside_has_ABBA
end

---@param ipv7 string
---@return boolean
local function support_ssl(ipv7)
    local abas, babs = {}, {}

    for _, subnet in _iter_ipv7, ipv7, 1 do
        if subnet.in_bracket then
            for _, bab in ipairs(_fetch_ABA(subnet.str)) do
                table.insert(babs, bab)
            end
        else
            for _, aba in ipairs(_fetch_ABA(subnet.str)) do
                table.insert(abas, aba)
            end
        end
    end

    for _, aba in ipairs(abas) do
        for _, bab in ipairs(babs) do
            if _is_ABA_match(aba, bab) then
                return true
            end
        end
    end

    return false
end

---@param input string
---@return integer
local function count_support_tls_ips(input)
    local count = 0
    for ipv7 in input:gmatch('[^\r\n]+') do
        if support_tls(ipv7) then
            count = count + 1
        end
    end
    return count
end

---@param input string
---@return integer
local function count_support_ssl_ips(input)
    local count = 0
    for ipv7 in input:gmatch('[^\r\n]+') do
        if support_ssl(ipv7) then
            count = count + 1
        end
    end
    return count
end

local M = {}
M._hasABBA = _has_ABBA
M._iter_ipv7 = _iter_ipv7
M.support_tls = support_tls
M.count_support_tls_ips = count_support_tls_ips
M.support_ssl = support_ssl
M.count_support_ssl_ips = count_support_ssl_ips
return M

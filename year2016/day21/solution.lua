---@param bytes integer[]
---@param x integer
---@param y integer
local function _swap_position(bytes, x, y)
    bytes[x], bytes[y] = bytes[y], bytes[x]
end

---@param bytes integer[]
---@param x integer
local function _find_index(bytes, x)
    for i = 1, #bytes do
        if bytes[i] == x then
            return i
        end
    end
    error(string.format('no %c found in %s', x, string.char(unpack(bytes))))
end

---@param bytes integer[]
---@param x integer
---@param y integer
local function _swap_letter(bytes, x, y)
    local i = _find_index(bytes, x)
    local j = _find_index(bytes, y)
    _swap_position(bytes, i, j)
end

---@param bytes integer[]
---@param aux integer[]
---@param steps integer
local function _rotate_left(bytes, aux, steps)
    while steps >= #bytes do
        steps = steps - #bytes
    end

    for i = 1, #bytes - steps do
        aux[i] = bytes[i + steps]
    end
    for i = #bytes - steps + 1, #bytes do
        aux[i] = bytes[i - #bytes + steps]
    end

    for i = 1, #bytes do
        bytes[i] = aux[i]
    end
end

---@param bytes integer[]
---@param aux integer[]
---@param steps integer
local function _rotate_right(bytes, aux, steps)
    while steps >= #bytes do
        steps = steps - #bytes
    end

    for i = 1, steps do
        aux[i] = bytes[i + #bytes - steps]
    end
    for i = steps + 1, #bytes do
        aux[i] = bytes[i - steps]
    end

    for i = 1, #bytes do
        bytes[i] = aux[i]
    end
end

---@param bytes integer[]
---@param aux integer[]
---@param x integer
local function _rotate_index(bytes, aux, x)
    local i = _find_index(bytes, x)
    local steps = i
    if i >= 5 then steps = steps + 1 end
    _rotate_right(bytes, aux, steps)
end

---@param bytes integer[]
---@param x integer
---@param y integer
local function _reverse_position(bytes, x, y)
    while x < y do
        _swap_position(bytes, x, y)
        x = x + 1
        y = y - 1
    end
end

---@param bytes integer[]
---@param aux integer[]
---@param x integer
---@param y integer
local function _move_position(bytes, aux, x, y)
    for i = 1, x - 1 do
        aux[i] = bytes[i]
    end
    local b = bytes[x]
    for i = x + 1, #bytes do
        aux[i - 1] = bytes[i]
    end

    for i = 1, y - 1 do
        bytes[i] = aux[i]
    end
    bytes[y] = b
    for i = y + 1, #bytes do
        bytes[i] = aux[i - 1]
    end
end

---@param s string
local function _must_tonumber(s)
    return assert(tonumber(s))
end

local _processes = {
    ---@param bytes integer[]
    ---@param aux integer[]
    ---@param line string
    function(bytes, aux, line)
        local x, y = line:match('swap position (%d+) with position (%d+)')
        if x ~= nil and y ~= nil then
            _swap_position(bytes, _must_tonumber(x) + 1, _must_tonumber(y) + 1)
            return true
        end
        return false
    end,
    ---@param bytes integer[]
    ---@param aux integer[]
    ---@param line string
    function(bytes, aux, line)
        local x, y = line:match('swap letter (%l) with letter (%l)')
        if x ~= nil and y ~= nil then
            _swap_letter(bytes, string.byte(x), string.byte(y))
            return true
        end
        return false
    end,
    ---@param bytes integer[]
    ---@param aux integer[]
    ---@param line string
    function(bytes, aux, line)
        local steps = line:match('rotate left (%d+) steps?')
        if steps ~= nil then
            _rotate_left(bytes, aux, _must_tonumber(steps))
            return true
        end
        return false
    end,
    ---@param bytes integer[]
    ---@param aux integer[]
    ---@param line string
    function(bytes, aux, line)
        local steps = line:match('rotate right (%d+) steps?')
        if steps ~= nil then
            _rotate_right(bytes, aux, _must_tonumber(steps))
            return true
        end
        return false
    end,
    ---@param bytes integer[]
    ---@param aux integer[]
    ---@param line string
    function(bytes, aux, line)
        local x = line:match('rotate based on position of letter (%l)')
        if x ~= nil then
            _rotate_index(bytes, aux, string.byte(x))
            return true
        end
        return false
    end,
    ---@param bytes integer[]
    ---@param aux integer[]
    ---@param line string
    function(bytes, aux, line)
        local x, y = line:match('reverse positions (%d+) through (%d+)')
        if x ~= nil and y ~= nil then
            _reverse_position(bytes, _must_tonumber(x) + 1, _must_tonumber(y) + 1)
            return true
        end
        return false
    end,
    ---@param bytes integer[]
    ---@param aux integer[]
    ---@param line string
    function(bytes, aux, line)
        local x, y = line:match('move position (%d+) to position (%d+)')
        if x ~= nil and y ~= nil then
            _move_position(bytes, aux, _must_tonumber(x) + 1, _must_tonumber(y) + 1)
            return true
        end
        return false
    end,
}

---@param bytes integer[]
---@param input string
local function _scramble_password(bytes, input)
    local aux = {}

    for line in input:gmatch('[^\r\n]+') do
        local processed = false

        for _, process in ipairs(_processes) do
            processed = process(bytes, aux, line)
            if processed then break end
        end

        if not processed then
            error(string.format('unknown operation: %s', line))
        end
    end
end

---@param passwd string
---@param input string
---@return string
local function scramble_password(passwd, input)
    local bytes = {}
    for i = 1, #passwd do
        bytes[i] = passwd:byte(i)
    end

    _scramble_password(bytes, input)
    return string.char(unpack(bytes))
end

---@param a integer[]
---@param n integer?
local function _permgen(a, n)
    n = n or #a
    if n <= 1 then
        coroutine.yield(a)
    else
        for i = 1, n do
            a[n], a[i] = a[i], a[n]
            _permgen(a, n - 1)
            a[n], a[i] = a[i], a[n]
        end
    end
end

---@param bytes integer[]
local function _permutations(bytes)
    local co = coroutine.create(function() _permgen(bytes) end)
    return function()
        local _, res = coroutine.resume(co)
        return res
    end
end

---@param scrambled string
---@param input string
---@return string
local function descramble_password(scrambled, input)
    local bytes = {}
    local target = {}
    for i = 1, #scrambled do
        bytes[i] = scrambled:byte(i)
        target[i] = scrambled:byte(i)
    end

    local copy = {}
    for p in _permutations(bytes) do
        for i = 1, #p do
            copy[i] = p[i]
        end

        _scramble_password(copy, input)

        local is_equal = true
        for i = 1, #scrambled do
            if copy[i] ~= target[i] then
                is_equal = false
                break
            end
        end
        if is_equal then
            return string.char(unpack(p))
        end
    end

    error('can not de-scramble')
end


local M = {}
M._rotate_left = _rotate_left
M._rotate_right = _rotate_right
M._move_position = _move_position
M.scramble_password = scramble_password
M.descramble_password = descramble_password
return M

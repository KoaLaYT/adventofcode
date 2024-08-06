local md5 = require('libs.openssl_md5')

---@class Generator
---@field _salt string
---@field _hash_cache table<integer, string>
local Generator = {}
Generator.__index = Generator

---@param salt string
---@return Generator
function Generator:new(salt)
    return setmetatable({
        _salt = salt,
        _hash_cache = {},
    }, self)
end

---@private
---@param idx integer
---@return string
function Generator:_hash(idx)
    local cached = self._hash_cache[idx]
    if cached == nil then
        cached = md5(string.format('%s%d', self._salt, idx))
        self._hash_cache[idx] = cached
    end
    return cached
end

---@private
---@param idx integer
---@return string
function Generator:_stretch_hash(idx)
    local cached = self._hash_cache[idx]
    if cached == nil then
        cached = md5(string.format('%s%d', self._salt, idx))
        for _ = 1, 2016 do
            cached = md5(cached)
        end
        self._hash_cache[idx] = cached
    end
    return cached
end

---@param hash string
---@return integer, boolean
local function _has_triplet(hash)
    for i = 1, #hash - 2 do
        local a = hash:byte(i)
        local b = hash:byte(i + 1)
        local c = hash:byte(i + 2)
        if a == b and b == c then
            return a, true
        end
    end
    return 0, false
end

---@param hash string
---@param byte integer
---@return boolean
local function _has_five_of_a_kind(hash, byte)
    for i = 1, #hash - 4 do
        local a = hash:byte(i)
        local b = hash:byte(i + 1)
        local c = hash:byte(i + 2)
        local d = hash:byte(i + 3)
        local e = hash:byte(i + 4)
        if a == byte and b == byte and c == byte and d == byte and e == byte then
            return true
        end
    end
    return false
end

---@private
---@param idx integer
---@param use_stretch boolean?
---@return boolean
function Generator:_is_key(idx, use_stretch)
    local hash = use_stretch and self:_stretch_hash(idx) or self:_hash(idx)

    local byte, ok = _has_triplet(hash)
    if not ok then return false end

    for i = idx + 1, idx + 1000 do
        local next_hash = use_stretch and self:_stretch_hash(i) or self:_hash(i)
        if _has_five_of_a_kind(next_hash, byte) then
            return true
        end
    end
    return false
end

---@param nth_key integer
---@return integer
function Generator:index(nth_key)
    local keys = 0
    for i = 1, math.huge do
        if self:_is_key(i) then
            keys = keys + 1
        end
        if keys == nth_key then
            return i
        end
    end

    error('unreachable')
end

---@param nth_key integer
---@return integer
function Generator:index_v2(nth_key)
    local keys = 0
    for i = 1, math.huge do
        if self:_is_key(i, true) then
            keys = keys + 1
        end
        if keys == nth_key then
            return i
        end
    end

    error('unreachable')
end

local M = {}
M.Generator = Generator
return M

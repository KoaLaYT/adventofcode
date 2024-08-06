local md5, err = require('resty.openssl.digest').new('md5')
if err ~= nil then error(err) end

---@param buf string
---@return string
local function _hex_dump(buf)
    ---@diagnostic disable-next-line: redundant-return-value
    return buf:gsub('.', function(c)
        return string.format('%02x', string.byte(c))
    end)
end

---@param input string
---@return string
local function openssl_md5(input)
    assert(md5:reset())
    md5:update(input)
    local digest = md5:final()
    return _hex_dump(digest)
end

return openssl_md5

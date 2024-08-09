---@class Computer
---@field registers table<string, integer>
---@field pc integer
---@field codes any[] # -- interface Code
---@field out integer[]
local Computer = {}
Computer.__index = Computer

--- INSTRUCTION CODES ---

---@class CodeCPYr
---@field src string
---@field dst string
local CodeCPYr = {}
CodeCPYr.__index = CodeCPYr
---@class CodeCPYv
---@field val integer
---@field dst string
local CodeCPYv = {}
CodeCPYv.__index = CodeCPYv
---@class CodeCPYi
---@field val integer
---@field amt integer
local CodeCPYi = {}
CodeCPYi.__index = CodeCPYi
---@class CodeCPYii
---@field reg string
---@field amt integer
local CodeCPYii = {}
CodeCPYii.__index = CodeCPYii
---@class CodeINC
---@field reg string
local CodeINC = {}
CodeINC.__index = CodeINC
---@class CodeDEC
---@field reg string
local CodeDEC = {}
CodeDEC.__index = CodeDEC
---@class CodeJNZr
---@field reg string
---@field amt integer
local CodeJNZr = {}
CodeJNZr.__index = CodeJNZr
---@class CodeJNZrr
---@field reg string
---@field amt string
local CodeJNZrr = {}
CodeJNZrr.__index = CodeJNZrr
---@class CodeJNZv
---@field val integer
---@field amt integer
local CodeJNZv = {}
CodeJNZv.__index = CodeJNZv
---@class CodeJNZvv
---@field val integer
---@field reg string
local CodeJNZvv = {}
CodeJNZvv.__index = CodeJNZvv
---@class CodeTGL
---@field reg string
local CodeTGL = {}
CodeTGL.__index = CodeTGL
---@class CodeOUT
---@field reg string
local CodeOUT = {}
CodeOUT.__index = CodeOUT

-------------------------------

---@param src string
---@param dst string
---@return CodeCPYr
function CodeCPYr:new(src, dst)
    return setmetatable({ src = src, dst = dst, }, self)
end

---@param c Computer
function CodeCPYr:update(c)
    c.registers[self.dst] = c.registers[self.src]
    c.pc = c.pc + 1
end

---@return CodeJNZrr
function CodeCPYr:toggled()
    return CodeJNZrr:new(self.src, self.dst)
end

function CodeCPYr:__tostring()
    return 'cpyr'
end

-------------------------------

---@param val integer
---@param dst string
---@return CodeCPYv
function CodeCPYv:new(val, dst)
    return setmetatable({ val = val, dst = dst, }, self)
end

---@param c Computer
function CodeCPYv:update(c)
    c.registers[self.dst] = self.val
    c.pc = c.pc + 1
end

---@return CodeJNZvv
function CodeCPYv:toggled()
    return CodeJNZvv:new(self.val, self.dst)
end

-------------------------------

---@param val integer
---@param amt integer
---@return CodeCPYi
function CodeCPYi:new(val, amt)
    return setmetatable({ val = val, amt = amt, }, self)
end

---@param c Computer
function CodeCPYi:update(c)
    -- do nothing
    c.pc = c.pc + 1
end

---@return CodeJNZv
function CodeCPYi:toggled()
    return CodeJNZv:new(self.val, self.amt)
end

-------------------------------

---@param reg string
---@param amt integer
---@return CodeCPYii
function CodeCPYii:new(reg, amt)
    return setmetatable({ reg = reg, amt = amt, }, self)
end

---@param c Computer
function CodeCPYii:update(c)
    -- do nothing
    c.pc = c.pc + 1
end

---@return CodeJNZr
function CodeCPYii:toggled()
    return CodeJNZr:new(self.reg, self.amt)
end

-------------------------------
---@param reg string
---@return CodeINC
function CodeINC:new(reg)
    return setmetatable({ reg = reg, }, self)
end

---@param c Computer
function CodeINC:update(c)
    c.registers[self.reg] = c.registers[self.reg] + 1
    c.pc = c.pc + 1
end

---@return CodeDEC
function CodeINC:toggled()
    return CodeDEC:new(self.reg)
end

function CodeINC:__tostring()
    return 'inc'
end

-------------------------------

---@param reg string
---@return CodeDEC
function CodeDEC:new(reg)
    return setmetatable({ reg = reg, }, self)
end

---@param c Computer
function CodeDEC:update(c)
    c.registers[self.reg] = c.registers[self.reg] - 1
    c.pc = c.pc + 1
end

---@return CodeINC
function CodeDEC:toggled()
    return CodeINC:new(self.reg)
end

function CodeDEC:__tostring()
    return 'dec'
end

-------------------------------

---@param reg string
---@param amt integer
---@return CodeJNZr
function CodeJNZr:new(reg, amt)
    return setmetatable({ reg = reg, amt = amt, }, self)
end

---@param c Computer
function CodeJNZr:update(c)
    local v = c.registers[self.reg]
    if v ~= 0 then
        c.pc = c.pc + self.amt
    else
        c.pc = c.pc + 1
    end
end

---@return CodeCPYii
function CodeJNZr:toggled()
    return CodeCPYii:new(self.reg, self.amt)
end

function CodeJNZr:__tostring()
    return 'jnzr' .. self.amt
end

-------------------------------

---@param reg string
---@param amt string
---@return CodeJNZrr
function CodeJNZrr:new(reg, amt)
    return setmetatable({ reg = reg, amt = amt, }, self)
end

---@param c Computer
function CodeJNZrr:update(c)
    local v = c.registers[self.reg]
    if v ~= 0 then
        c.pc = c.pc + c.registers[self.amt]
    else
        c.pc = c.pc + 1
    end
end

---@return CodeCPYr
function CodeJNZrr:toggled()
    return CodeCPYr:new(self.reg, self.amt)
end

-------------------------------

---@param val integer
---@param amt integer
---@return CodeJNZv
function CodeJNZv:new(val, amt)
    return setmetatable({ val = val, amt = amt, }, self)
end

---@param c Computer
function CodeJNZv:update(c)
    if self.val ~= 0 then
        c.pc = c.pc + self.amt
    else
        c.pc = c.pc + 1
    end
end

---@return CodeCPYi
function CodeJNZv:toggled()
    return CodeCPYi:new(self.val, self.amt)
end

-------------------------------

---@param val integer
---@param reg string
---@return CodeJNZvv
function CodeJNZvv:new(val, reg)
    return setmetatable({ val = val, reg = reg, }, self)
end

---@param c Computer
function CodeJNZvv:update(c)
    if self.val ~= 0 then
        c.pc = c.pc + c.registers[self.reg]
    else
        c.pc = c.pc + 1
    end
end

---@return CodeCPYv
function CodeJNZvv:toggled()
    return CodeCPYv:new(self.val, self.reg)
end

-------------------------------

---@param reg string
---@return CodeTGL
function CodeTGL:new(reg)
    return setmetatable({ reg = reg, }, self)
end

---@param c Computer
function CodeTGL:update(c)
    local idx = c.pc + c.registers[self.reg]
    local code = c.codes[idx]
    if code ~= nil then
        c.codes[idx] = code:toggled()
    end
    c.pc = c.pc + 1
end

---@return CodeINC
function CodeTGL:toggled()
    return CodeINC:new(self.reg)
end

-------------------------------

---@param reg string
---@return CodeOUT
function CodeOUT:new(reg)
    return setmetatable({ reg = reg, }, self)
end

---@param c Computer
function CodeOUT:update(c)
    table.insert(c.out, c.registers[self.reg])
    c.pc = c.pc + 1
end

---@return CodeINC
function CodeOUT:toggled()
    return CodeINC:new(self.reg)
end

-------------------------------

---@param input string
---@return Computer
function Computer:new(input)
    local codes = {}
    for line in input:gmatch('[^\r\n]+') do
        local parsed = false

        do
            local src, dst = line:match('^cpy (%l) (%l)$')
            if src ~= nil and dst ~= nil then
                table.insert(codes, CodeCPYr:new(src, dst))
                parsed = true
            end
        end
        do
            local val, dst = line:match('^cpy (-?%d+) (%l)$')
            if val ~= nil and dst ~= nil then
                table.insert(codes, CodeCPYv:new(assert(tonumber(val)), dst))
                parsed = true
            end
        end
        do
            local reg = line:match('^inc (%l)$')
            if reg ~= nil then
                table.insert(codes, CodeINC:new(reg))
                parsed = true
            end
        end
        do
            local reg = line:match('^dec (%l)$')
            if reg ~= nil then
                table.insert(codes, CodeDEC:new(reg))
                parsed = true
            end
        end
        do
            local reg, amt = line:match('^jnz (%l) (-?%d+)$')
            if reg ~= nil and amt ~= nil then
                table.insert(codes, #codes + 1, CodeJNZr:new(reg, assert(tonumber(amt))))
                parsed = true
            end
        end
        do
            local val, amt = line:match('^jnz (-?%d+) (-?%d+)$')
            if val ~= nil and amt ~= nil then
                table.insert(codes, #codes + 1, CodeJNZv:new(assert(tonumber(val)), assert(tonumber(amt))))
                parsed = true
            end
        end
        do
            local val, reg = line:match('^jnz (-?%d+) (%l)$')
            if val ~= nil and reg ~= nil then
                table.insert(codes, CodeJNZvv:new(assert(tonumber(val)), reg))
                parsed = true
            end
        end
        do
            local reg = line:match('^tgl (%l)$')
            if reg ~= nil then
                table.insert(codes, CodeTGL:new(reg))
                parsed = true
            end
        end
        do
            local reg = line:match('^out (%l)$')
            if reg ~= nil then
                table.insert(codes, CodeOUT:new(reg))
                parsed = true
            end
        end

        if not parsed then
            error(string.format('unknown code: %s', line))
        end
    end

    return setmetatable({
        registers = { a = 0, b = 0, c = 0, d = 0, },
        pc = 1,
        codes = codes,
        out = {},
    }, self)
end

function Computer:_multiple_loop()
    local pc = self.pc
    local c1 = self.codes[pc]
    local c2 = self.codes[pc + 1]
    local c3 = self.codes[pc + 2]
    local c4 = self.codes[pc + 3]
    local c5 = self.codes[pc + 4]
    local c6 = self.codes[pc + 5]

    if tostring(c1) == 'cpyr' and
        tostring(c2) == 'inc' and
        tostring(c3) == 'dec' and
        tostring(c4) == 'jnzr-2' and
        tostring(c5) == 'dec' and
        tostring(c6) == 'jnzr-5' then
        if c1.dst == c3.reg and c1.dst == c4.reg and c5.reg == c6.reg then
            local v = self.registers[c1.src] * self.registers[c5.reg]
            self.registers[c2.reg] = self.registers[c2.reg] + v
            return true
        end
    end

    return false
end

---@param max_out_len integer?
function Computer:run(max_out_len)
    max_out_len = max_out_len or 100

    while self.pc <= #self.codes do
        -- find multiple
        if self:_multiple_loop() then
            self.pc = self.pc + 6
        else
            self.codes[self.pc]:update(self)
        end

        if #self.out == max_out_len then break end
    end
end

---@param reg string
---@return integer
function Computer:register(reg)
    return self.registers[reg]
end

---@param reg string
---@param val integer
function Computer:set_register(reg, val)
    self.registers[reg] = val
end

function Computer:reset()
    self.registers = { a = 0, b = 0, c = 0, d = 0, }
    self.pc = 1
    self.out = {}
end

---@return integer
function Computer:find_right_signal()
    for i = 1, math.huge do
        self:reset()
        self:set_register('a', i)
        self:run(20)

        local is_right_signal = true
        for j = 2, #self.out, 2 do
            if self.out[j - 1] ~= 0 or self.out[j] ~= 1 then
                is_right_signal = false
                break
            end
        end

        if is_right_signal then return i end
    end

    error('can not find right signal')
end

local M = {}
M.Computer = Computer
return M

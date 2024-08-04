---@class Computer
---@field registers table<string, integer>
---@field pc integer
---@field codes any[] # -- interface Code
local Computer = {}
Computer.__index = Computer

---@class CodeCPYr
---@field src string
---@field dst string
local CodeCPYr = {}
CodeCPYr.__index = CodeCPYr

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

---@class CodeCPYv
---@field val integer
---@field dst string
local CodeCPYv = {}
CodeCPYv.__index = CodeCPYv

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

---@class CodeINC
---@field reg string
local CodeINC = {}
CodeINC.__index = CodeINC

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

---@class CodeDEC
---@field reg string
local CodeDEC = {}
CodeDEC.__index = CodeDEC

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

---@class CodeJNZr
---@field reg string
---@field amt integer
local CodeJNZr = {}
CodeJNZr.__index = CodeJNZr

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

---@class CodeJNZv
---@field val integer
---@field amt integer
local CodeJNZv = {}
CodeJNZv.__index = CodeJNZv

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
                table.insert(codes, CodeJNZr:new(reg, assert(tonumber(amt))))
                parsed = true
            end
        end
        do
            local val, amt = line:match('^jnz (-?%d+) (-?%d+)$')
            if val ~= nil and amt ~= nil then
                table.insert(codes, CodeJNZv:new(assert(tonumber(val)), assert(tonumber(amt))))
                parsed = true
            end
        end

        if not parsed then
            error(string.format('unknown code: %s', line))
        end
    end

    local registers = { a = 0, b = 0, c = 0, d = 0, }

    return setmetatable({
        registers = registers,
        pc = 1,
        codes = codes,
    }, self)
end

function Computer:run()
    while self.pc <= #self.codes do
        self.codes[self.pc]:update(self)
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

local M = {}
M.Computer = Computer
return M

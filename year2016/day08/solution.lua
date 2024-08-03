---@class Screen
---@field front boolean[][]
---@field back  boolean[][]
---@field row   integer
---@field col   integer
local Screen = {}
Screen.__index = Screen

---@param row integer
---@param col integer
---@return Screen
function Screen:new(row, col)
    local front = {}
    local back = {}
    for _ = 1, row do
        local front_row = {}
        local back_row = {}
        for _ = 1, col do
            table.insert(front_row, false)
            table.insert(back_row, false)
        end
        table.insert(front, front_row)
        table.insert(back, back_row)
    end
    return setmetatable({
        front = front,
        back = back,
        row = row,
        col = col,
    }, self)
end

---@return integer
function Screen:litted()
    local litted = 0
    for i = 1, self.row do
        for j = 1, self.col do
            if self.front[i][j] then
                litted = litted + 1
            end
        end
    end
    return litted
end

---@return string
function Screen:reveal_code()
    local str = ''
    for i = 1, self.row do
        local row = {}
        for j = 1, self.col do
            if self.front[i][j] then
                table.insert(row, string.byte('#'))
            else
                table.insert(row, string.byte(' '))
            end
        end
        str = str .. string.char(unpack(row))
        if i < self.row then
            str = str .. '\n'
        end
    end
    return str
end

---@return string
function Screen:__tostring()
    local str = ''
    for i = 1, self.row do
        local row = {}
        for j = 1, self.col do
            if self.front[i][j] then
                table.insert(row, string.byte('#'))
            else
                table.insert(row, string.byte('.'))
            end
        end
        str = str .. string.char(unpack(row))
        str = str .. '\n'
    end
    return str
end

---@class RectOp
---@field width  integer
---@field height integer
local RectOp = {}
RectOp.__index = RectOp

---@param width integer
---@param height integer
---@return RectOp
function RectOp:new(width, height)
    return setmetatable({
        width = width,
        height = height,
    }, self)
end

---@param screen Screen
function RectOp:update(screen)
    for i = 1, screen.row do
        for j = 1, screen.col do
            if i <= self.height and j <= self.width then
                screen.back[i][j] = true
            else
                screen.back[i][j] = screen.front[i][j]
            end
        end
    end
    screen.front, screen.back = screen.back, screen.front
end

---@class RotateColOp
---@field col    integer
---@field amount integer
local RotateColOp = {}
RotateColOp.__index = RotateColOp

---@param col integer
---@param amount integer
---@return RotateColOp
function RotateColOp:new(col, amount)
    return setmetatable({
        col = col,
        amount = amount,
    }, self)
end

---@param screen Screen
function RotateColOp:update(screen)
    for i = 1, screen.row do
        for j = 1, screen.col do
            if self.col == j then
                local row = i + self.amount
                if row > screen.row then
                    row = row - screen.row
                end
                screen.back[row][j] = screen.front[i][j]
            else
                screen.back[i][j] = screen.front[i][j]
            end
        end
    end
    screen.front, screen.back = screen.back, screen.front
end

---@class RotateRowOp
---@field row    integer
---@field amount integer
local RotateRowOp = {}
RotateRowOp.__index = RotateRowOp

---@param row integer
---@param amount integer
---@return RotateRowOp
function RotateRowOp:new(row, amount)
    return setmetatable({
        row = row,
        amount = amount,
    }, self)
end

---@param screen Screen
function RotateRowOp:update(screen)
    for i = 1, screen.row do
        for j = 1, screen.col do
            if self.row == i then
                local col = j + self.amount
                if col > screen.col then
                    col = col - screen.col
                end
                screen.back[i][col] = screen.front[i][j]
            else
                screen.back[i][j] = screen.front[i][j]
            end
        end
    end
    screen.front, screen.back = screen.back, screen.front
end

---@param str string
---@return RectOp | RotateRowOp | RotateColOp
local function parse_op(str)
    do
        local width, height = str:match('^rect (%d+)x(%d+)$')
        if width ~= nil and height ~= nil then
            ---@diagnostic disable-next-line: param-type-mismatch
            return RectOp:new(tonumber(width), tonumber(height))
        end
    end
    do
        local row, amount = str:match('^rotate row y=(%d+) by (%d+)$')
        if row ~= nil and amount ~= nil then
            ---@diagnostic disable-next-line: param-type-mismatch
            return RotateRowOp:new(tonumber(row) + 1, tonumber(amount))
        end
    end
    do
        local col, amount = str:match('^rotate column x=(%d+) by (%d+)$')
        if col ~= nil and amount ~= nil then
            ---@diagnostic disable-next-line: param-type-mismatch
            return RotateColOp:new(tonumber(col) + 1, tonumber(amount))
        end
    end

    error(string.format('unknown operation: %s', str))
end

---@param input string
function Screen:update(input)
    for line in input:gmatch('[^\r\n]+') do
        parse_op(line):update(self)
    end
end

local M = {}
M.Screen = Screen
M.RectOp = RectOp
M.RotateColOp = RotateColOp
M.RotateRowOp = RotateRowOp
M.parse_op = parse_op
return M

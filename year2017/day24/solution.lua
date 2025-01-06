---@class Component
---@field a integer
---@field b integer
local Component = {}
Component.__index = Component

---@param input string
---@return Component
function Component:new(input)
  local i = input:find('/')
  local a = input:sub(1, i - 1)
  local b = input:sub(i + 1)
  return setmetatable({
    a = assert(tonumber(a)),
    b = assert(tonumber(b)),
  }, self)
end

---@return string
function Component:__tostring()
  return string.format('%d/%d', self.a, self.b)
end

---@param input string
---@return Component[]
local function parse_components(input)
  local cs = {}
  for row in input:gmatch('[^\r\n]+') do
    table.insert(cs, Component:new(row))
  end
  return cs
end


---@param cs Component[]
---@param selected table<integer, boolean>
local function strength(cs, selected)
  local result = 0
  for k, v in pairs(selected) do
    if v then
      local c = cs[k]
      result = result + c.a + c.b
    end
  end
  return result
end

---@param selected table<integer, boolean>
---@return integer
local function selected_size(selected)
  local size = 0
  for _, v in pairs(selected) do
    if v then size = size + 1 end
  end
  return size
end

---@param cs Component[]
---@param selected table<integer, boolean>
---@param next_port integer
local function _longest_strongest(cs, selected, next_port)
  local max = strength(cs, selected)
  local length = selected_size(selected)

  for i, c in ipairs(cs) do
    if not selected[i] then
      if c.a == next_port then
        selected[i] = true
        local l, s = _longest_strongest(cs, selected, c.b)
        if l >= length then
          length = l
          max = math.max(max, s)
        end
        selected[i] = false
      end
      if c.b ~= c.a and c.b == next_port then
        selected[i] = true
        local l, s = _longest_strongest(cs, selected, c.a)
        if l >= length then
          length = l
          max = math.max(max, s)
        end
        selected[i] = false
      end
    end
  end

  return length, max
end

---@param cs Component[]
---@param selected table<integer, boolean>
---@param next_port integer
local function _strongest(cs, selected, next_port)
  local max = strength(cs, selected)

  for i, c in ipairs(cs) do
    if not selected[i] then
      if c.a == next_port then
        selected[i] = true
        max = math.max(max, _strongest(cs, selected, c.b))
        selected[i] = false
      end
      if c.b ~= c.a and c.b == next_port then
        selected[i] = true
        max = math.max(max, _strongest(cs, selected, c.a))
        selected[i] = false
      end
    end
  end

  return max
end

---@param input string
---@return integer
local function strongest(input)
  local cs = parse_components(input)
  local max = 0
  for i, c in ipairs(cs) do
    if c.a == 0 then
      max = math.max(max, _strongest(cs, { [i] = true, }, c.b))
    end
    if c.b == 0 then
      max = math.max(max, _strongest(cs, { [i] = true, }, c.a))
    end
  end
  return max
end

---@param input string
---@return integer
local function longest_strongest(input)
  local cs = parse_components(input)
  local max = 0
  local length = 0
  for i, c in ipairs(cs) do
    if c.a == 0 then
      local l, s = _longest_strongest(cs, { [i] = true, }, c.b)
      if l >= length then
        length = l
        max = math.max(max, s)
      end
    end
    if c.b == 0 then
      local l, s = _longest_strongest(cs, { [i] = true, }, c.a)
      if l >= length then
        length = l
        max = math.max(max, s)
      end
    end
  end
  return max
end

local M = {}
M.Component = Component
M.strongest = strongest
M.longest_strongest = longest_strongest
return M


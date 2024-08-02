local h = require('libs.helper')

---@param s string
---@return integer[]
local function parse_triangle(s)
    local result = {}
    for ss in s:gmatch('[0-9]+') do
        local num = h.parse_integer(ss, 1)
        table.insert(result, #result + 1, num)
    end
    return result
end

---@param sides integer[]
---@return boolean
local function is_possible_triangle(sides)
    local x, y, z = sides[1], sides[2], sides[3]
    if x + y <= z then return false end
    if x + z <= y then return false end
    if y + z <= x then return false end
    return true
end

---@param input string
---@return integer
local function count_possible_triangles(input)
    local result = 0
    for line in input:gmatch('[^\r\n]+') do
        local sides = parse_triangle(line)
        if is_possible_triangle(sides) then
            result = result + 1
        end
    end
    return result
end

---@param input string
---@return integer
local function count_possible_triangles_vertically(input)
    local side = 0
    local triangles = {}
    local result = 0

    for line in input:gmatch('[^\r\n]+') do
        if side == 0 then
            triangles = {}
            table.insert(triangles, {})
            table.insert(triangles, {})
            table.insert(triangles, {})
        end

        local sides = parse_triangle(line)
        table.insert(triangles[#triangles - 2], side + 1, sides[1])
        table.insert(triangles[#triangles - 1], side + 1, sides[2])
        table.insert(triangles[#triangles], side + 1, sides[3])

        if side == 2 then
            for _, triangle in ipairs(triangles) do
                if is_possible_triangle(triangle) then
                    result = result + 1
                end
            end
        end

        side = (side + 1) % 3
    end

    return result
end

local M = {}
M.parse_triangle = parse_triangle
M.is_possible_triangle = is_possible_triangle
M.count_possible_triangles = count_possible_triangles
M.count_possible_triangles_vertically = count_possible_triangles_vertically
return M

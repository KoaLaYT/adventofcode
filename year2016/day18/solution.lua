local dot = string.byte('.')
local caret = string.byte('^')

---@param s string
---@return integer[]
local function _string_to_bytes(s)
    local result = {}
    for i = 1, #s do
        result[i] = s:byte(i)
    end
    return result
end

---@param row integer[]
---@return integer
local function _count_safe_tiles_one_row(row)
    local result = 0
    for i = 1, #row do
        if row[i] == dot then
            result = result + 1
        end
    end
    return result
end

---@param first_row string
---@param total_rows integer
---@return integer
local function count_safe_tiles(first_row, total_rows)
    local curr_row = _string_to_bytes(first_row)
    local next_row = {}
    local safe_tiles = 0

    for _ = 1, total_rows do
        safe_tiles = safe_tiles + _count_safe_tiles_one_row(curr_row)

        for i = 1, #curr_row do
            local left_safe = i == 1 or curr_row[i - 1] == dot
            local curr_safe = curr_row[i] == dot
            local right_safe = i == #curr_row or curr_row[i + 1] == dot

            if not left_safe and not curr_safe and right_safe then
                next_row[i] = caret
            elseif left_safe and not curr_safe and not right_safe then
                next_row[i] = caret
            elseif not left_safe and curr_safe and right_safe then
                next_row[i] = caret
            elseif left_safe and curr_safe and not right_safe then
                next_row[i] = caret
            else
                next_row[i] = dot
            end
        end

        curr_row, next_row = next_row, curr_row
    end

    return safe_tiles
end

local M = {}
M.count_safe_tiles = count_safe_tiles
return M

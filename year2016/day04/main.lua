local h = require('libs.helper')
local s = require('day04.solution')

h.solve('Part One', function()
    local input = h.getinput()
    return s.sum_real_room_ids(input)
end)

h.solve('Part Two', function()
    local input = h.getinput()
    local room_id, decrypted, raw = s.find_room(input, 'northpole')
    print('Decrypt: ' .. raw .. ' => ' .. decrypted)
    return room_id
end)

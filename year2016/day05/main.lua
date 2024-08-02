local h = require('libs.helper')
local s = require('day05.solution')

local prefix = 'ojvtpuvg'

h.solve('Part One', function()
    return s.find_password(prefix, '00000')
end)

h.solve('Part Two', function()
    return s.find_password_v2(prefix, '00000')
end)

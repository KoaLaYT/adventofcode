local h = require('libs.helper')
local s = require('day07.solution')

h.solve('Part One', function()
    local input = h.getinput()
    return s.count_support_tls_ips(input)
end)

h.solve('Part Two', function()
    local input = h.getinput()
    return s.count_support_ssl_ips(input)
end)

local h = require('libs.helper')
local s = require('day15.solution')

h.solve('Part One', function()
    local sculpture = s.Sculpture:new({
        s.Disc:new(11, 13),
        s.Disc:new(0, 5),
        s.Disc:new(11, 17),
        s.Disc:new(0, 3),
        s.Disc:new(2, 7),
        s.Disc:new(17, 19),
    })
    return sculpture:first_time_get_capsule()
end)

h.solve('Part Two', function()
    local sculpture = s.Sculpture:new({
        s.Disc:new(11, 13),
        s.Disc:new(0, 5),
        s.Disc:new(11, 17),
        s.Disc:new(0, 3),
        s.Disc:new(2, 7),
        s.Disc:new(17, 19),
        s.Disc:new(0, 11),
    })
    return sculpture:first_time_get_capsule()
end)

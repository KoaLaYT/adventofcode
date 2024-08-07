local test = require('libs.test')
local s = require('day15.solution')

test('Sculpture:first_time_get_capsule', function(a)
    local sculpture = s.Sculpture:new({
        s.Disc:new(4, 5),
        s.Disc:new(1, 2),
    })

    a.equal(sculpture:first_time_get_capsule(), 5)
end)

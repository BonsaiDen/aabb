local StaticBox = require('Static', ...)
local MovingBox = class(StaticBox)

function MovingBox:new(pos, size)
    StaticBox.new(self, pos, size)
end

function MovingBox:update(dt)
    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y
    self:updateBounds()
end

function MovingBox:draw()

    local x = self.pos.x
    local y = self.pos.y
    local sx = self.size.x
    local sy = self.size.y
    local cx = x + sx / 2
    local cy = y + sy / 2
    local vx = self.vel.x
    local vy = self.vel.y
    local vl = math.sqrt(vx * vx + vy * vy)

    love.graphics.setColor(0, 255, 0)
    game.drawBox(x, y, sx, sy)

    love.graphics.setColor(0, 0, 255)
    game.drawLine(cx, cy, cx + vx / vl * 10, cy + vy / vl * 10, 2)

end

return MovingBox


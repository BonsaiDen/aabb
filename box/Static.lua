StaticBox = class()
StaticBox.id = 0

function StaticBox:new(pos, size)

    self.id = StaticBox.id
    StaticBox.id = StaticBox.id + 1

    self.pos = pos or { x = 0, y = 0 }
    self.size = size or { x = 16, y = 16}

    self.vel = { x = 0, y = 0 }
    self.min = { x = 0, y = 0 }
    self.max = { x = 0, y = 0 }

    self.blocks = {
        up = true,
        right = true,
        down = true,
        left = true
    }

    self:updateBounds()

end

function StaticBox:updateBounds()
    self.max.x = self.pos.x + self.size.x 
    self.min.x = self.pos.x 
    self.max.y = self.pos.y + self.size.y 
    self.min.y = self.pos.y 
end

function StaticBox:overlaps(other)

    if self.max.x < other.min.x or self.min.x > other.max.x then 
        return false

    elseif self.max.y < other.min.y or self.min.y > other.max.y then 
        return false 

    else
        return true;
    end

end

function StaticBox:within(min, max)
    return self.min.x < max.x and self.min.y < max.y
            and self.max.x > min.x and self.max.y > min.y
end

function StaticBox:contains(point)
    return self.min.x < point.x and self.min.y < point.y
            and self.max.x > point.x and self.max.y > point.y
end

function StaticBox:draw()
    love.graphics.setColor(200, 0, 0)
    game.drawBox(self.pos.x, self.pos.y, self.size.x, self.size.y)
end


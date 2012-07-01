local StaticBox = require('Static', ...)
local DynamicBox = class(StaticBox)

function DynamicBox:new(pos, size)

    StaticBox.new(self, pos, size)

    -- TODO these should to be lists 
    self.contactSurface = {
        up = nil,
        right = nil,
        down = nil,
        left = nil
    }

    self.hitSurface = {
        up = nil,
        right = nil,
        down = nil,
        left = nil
    }

end

function DynamicBox:beforeUpdate(dt)

    self.hitSurface.up = nil
    self.hitSurface.down = nil
    self.hitSurface.right = nil
    self.hitSurface.left = nil

    self.contactSurface.up = nil
    self.contactSurface.down = nil
    self.contactSurface.right = nil
    self.contactSurface.left = nil

end

function DynamicBox:update(dt)
    self:updatePosition(dt)
    self:updateBounds()
end

function DynamicBox:updatePosition(dt)
    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y
end

function DynamicBox:setPosition(pos) 
    self.pos.x = math.round(pos.x)
    self.pos.y = math.round(pos.y)
    self.vel.x = 0
    self.vel.y = 0
    self:updateBounds()
end

function DynamicBox:draw()

    local x = self.pos.x
    local y = self.pos.y
    local sx = self.size.x
    local sy = self.size.y
    local cx = x + sx / 2
    local cy = y + sy / 2
    local vx = self.vel.x
    local vy = self.vel.y
    local vl = math.sqrt(vx * vx + vy * vy)

    love.graphics.setColor(255, 255, 0)
    game.drawBox(x, y, sx, sy)

    love.graphics.setColor(0, 0, 255)
    game.drawLine(cx, cy, cx + vx / vl * 10, cy + vy / vl * 10, 2)

    love.graphics.setColor(0, 0, 255)
    if self.contactSurface.down then
        game.drawLine(x, y + sy, x + sx, y + sy, 2)
    end

    if self.contactSurface.up then
        game.drawLine(x, y, x + sx, y, 2)
    end

    if self.contactSurface.left then
        game.drawLine(x, y, x, y + sy, 2)
    end

    if self.contactSurface.right then
        game.drawLine(x + sx, y, x + sx, y  + sy, 2)
    end

end

function DynamicBox:onCollision(other, vel, normal)

    self.vel.x = self.vel.x + vel.x
    self.vel.y = self.vel.y + vel.y

    if normal.y == 1 then
        self.hitSurface.down = other

    elseif normal.y == -1 then
        self.hitSurface.up = other
    end

    if normal.x == 1 then
        self.hitSurface.right = other

    elseif normal.x == -1 then
        self.hitSurface.left = other
    end

end

function DynamicBox:sweep(other, otherVel)

    local a = self
    local b = other
    local v = { x = a.vel.x - b.vel.x, y = a.vel.y - b.vel.y }

    if otherVel then
        v.x = v.x + otherVel.x
        v.y = v.y + otherVel.y
    end

    local hitTime = 0
    local outTime = 1
    local overlapsTime = {
        x = 0,
        y = 0
    }

    local outVel = { x = 0, y = 0 }

    -- invert v, since we're treating b as stationary here
    v.x = -v.x
    v.y = -v.y
    
    -- X axis overlap
    if v.x < 0 then
        if not b.blocks.right then return false, nil, nil end
        if b.max.x < a.min.x then return false, nil, nil end
        if b.max.x > a.min.x then
            outTime = math.min((a.min.x - b.max.x) / v.x, outTime)
        end

        if a.max.x < b.min.x then
            overlapsTime.x = (a.max.x - b.min.x) / v.x
            hitTime = math.max(overlapsTime.x, hitTime)
        end

    elseif v.x > 0 then
        if not b.blocks.left then return false, nil, nil end
        if b.min.x > a.max.x then return false, nil, nil end
        if a.max.x > b.min.x then
            outTime = math.min((a.max.x - b.min.x) / v.x, outTime)
        end

        if b.max.x < a.min.x then
            overlapsTime.x = (a.min.x - b.max.x) / v.x
            hitTime = math.max(overlapsTime.x, hitTime)
        end

    end

    if hitTime > outTime then return false, nil, nil end

    -- Y axis overlap
    if v.y < 0 then
        if not b.blocks.down then return false, nil, nil end
        if b.max.y < a.min.y then return false, nil, nil end
        if b.max.y > a.min.y then
            outTime = math.min((a.min.y - b.max.y) / v.y, outTime)
        end

        if a.max.y < b.min.y then
            overlapsTime.y = (a.max.y - b.min.y) / v.y
            hitTime = math.max(overlapsTime.y, hitTime)
        end

    elseif v.y > 0 then
        if not b.blocks.up then return false, nil, nil end
        if b.min.y > a.max.y then return false, nil, nil end
        if a.max.y > b.min.y then
            outTime = math.min((a.max.y - b.min.y) / v.y, outTime)
        end

        if b.max.y < a.min.y then
            overlapsTime.y = (a.min.y - b.max.y) / v.y
            hitTime = math.max(overlapsTime.y, hitTime)
        end

    end

    if hitTime > outTime then return false, nil, nil end

    -- the correction to the current velocity
    outVel.x = (v.x - (v.x * hitTime))
    outVel.y = (v.y - (v.y * hitTime))

    -- IMPORTANT
    -- since hitTime defaults to 0, everything that's
    -- somehwere along an axis will eventually collided at "0"
    -- thus, we bail out in case of <= 0 to prevent "ghosting" collisions
    -- BUT: In order to stop at objects, we need to NOT bail out in case we overlap
    if (hitTime <= 0 and not a:overlaps(b)) or hitTime > 1 or hitTime > outTime then 
        return false, nil, nil
    end

    -- allow for sliding on surfaces
    if a.max.y - b.min.y == 0 or a.min.y - b.max.y == 0 then
        outVel.x = 0
    end

    if a.max.x - b.min.x == 0 or a.min.x - b.max.x == 0 then
        outVel.y = 0
    end

    local hitNormal = {
        x = (outVel.x < 0) and 1 or ((outVel.x > 0) and -1 or 0),
        y = (outVel.y < 0) and 1 or ((outVel.y > 0) and -1 or 0)
    }

    -- allow us to get away if we're in contact but are moving into the opposite
    -- direction
    if hitTime == 0 then

        -- return false in case we're trying to move away
        if v.x > 0 and a.max.x <= b.min.x then
            return false, nil, nil

        elseif v.x < 0 and a.min.x >= b.max.x then
            return false, nil, nil
        end

        if v.y > 0 and a.max.y <= b.min.y then
            return false, nil, nil

        elseif v.y < 0 and a.min.y >= b.max.y then
            return false, nil, nil
        end

        -- otherwise set the contact surface
        if a.min.x < b.max.x and a.max.x > b.min.x then
            if a.max.y == b.min.y then
                self.contactSurface.down = b

            elseif a.min.y == b.max.y then
                self.contactSurface.up = b
            end
        end

        if a.min.y < b.max.y and a.max.y > b.min.y then
            if a.max.x == b.min.x then
                self.contactSurface.right = b

            elseif a.min.x == b.max.x then
                self.contactSurface.left = b
            end
        end

        -- in case we're stuck make sure push us out
        local pushVel = {
            x = 0,
            y = 0
        }

        -- Resolve boxes which are stuck
        if not (self.max.x < other.min.x + 1 or self.min.x > other.max.x - 1) 
            and not (self.max.y < other.min.y + 1 or self.min.y > other.max.y - 1) then 

            -- compute centers
            local acy = a.min.y + a.size.y / 2
            local bcy = b.min.y + b.size.y / 2

            if acy < bcy then
                pushVel.y = b.min.y - a.max.y

            else
                pushVel.y = b.max.y - a.min.y
            end

            -- compute centers
            local acx = a.min.x + a.size.x / 2
            local bcx = b.min.x + b.size.x / 2

            if acx < bcx then
                pushVel.x = b.min.x - a.max.x

            else
                pushVel.x = b.max.x - a.min.x
            end

            -- now choose the minium / maximum of the push / out values
            -- to resolve the stuck state in the "best" way
            if math.abs(pushVel.y) < math.abs(pushVel.x) then
                outVel.y = math.minmax(pushVel.y, outVel.y)

            elseif math.abs(pushVel.x) > math.abs(pushVel.y) then
                outVel.x = math.minmax(pushVel.x, outVel.x)

            else
                outVel.y = math.minmax(pushVel.y, outVel.y)
                outVel.x = math.minmax(pushVel.x, outVel.x)
            end

        end

    end

    -- final correction for ghosting artifacts
    if outVel.y ~= 0 and not (a.min.x < b.max.x and a.max.x > b.min.x) then

        -- only return in case x is also 0, otherwise we'll clip into walls
        -- in case of diagonal movement
        if outVel.x == 0 then
            return false, nil, nil

        else
            hitNormal.y = 0
            outVel.y = 0
        end

    end

    if outVel.x ~= 0 and not (a.min.y < b.max.y and a.max.y > b.min.y) then

        -- only return in case x is also 0, otherwise we'll clip into floors
        -- in case of diagonal movement
        if outVel.y == 0 then
            return false, nil, nil

        else
            hitNormal.x = 0
            outVel.x = 0
        end

    end

    return true, outVel, hitNormal

end

return DynamicBox


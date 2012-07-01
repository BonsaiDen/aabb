-- ----------------------------------------------------------------------------
-- Static AABB Box ------------------------------------------------------------
-- ----------------------------------------------------------------------------
local StaticBox = class()
StaticBox.id = 0

function StaticBox:new(x, y, w, h)
    self.id = StaticBox.id
    StaticBox.id = StaticBox.id + 1

    self.pos = { x = x, y = y }
    self.size = { x = w, y = h }

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

function StaticBox:within(x, y, mx, my)
    return self.min.x < mx and self.min.y < my
            and self.max.x > x and self.max.y > y
end

function StaticBox:contains(point)
    return self.min.x < point.x and self.min.y < point.y
            and self.max.x > point.x and self.max.y > point.y
end

function StaticBox:draw()
    game.graphics.setColor(200, 0, 0)
    game.graphics.rectangle(self.pos.x, self.pos.y, self.size.x, self.size.y)
end
-- End Static ------------------------------------------------------------------



-- ----------------------------------------------------------------------------
-- Static Box Grid ------------------------------------------------------------
-- ----------------------------------------------------------------------------
local StaticBoxGrid = class()
function StaticBoxGrid:new(spacing)
    -- this should be bigger then the maximum square size of any dynamic object
    self.spacing = spacing or 64 
    self.buckets = {}
    self.empty = {}

    self.boxes = {}
end

function StaticBoxGrid:add(box)
    table.insert(self.boxes, box)

    self:eachIn(box.min.x, box.min.y, box.max.x, box.max.y, function(x, y, hash)
    
        if not self.buckets[hash] then
            self.buckets[hash] = {}
        end

        table.insert(self.buckets[hash], box)

    end)
end

function StaticBoxGrid:eachIn(x, y, mx, my, callback)
    local minx = math.floor(x / self.spacing) * self.spacing - self.spacing
    local maxx = math.floor(mx / self.spacing) * self.spacing + self.spacing

    local miny = math.floor(y / self.spacing) * self.spacing - self.spacing
    local maxy = math.floor(my / self.spacing) * self.spacing + self.spacing

    for y=miny, maxy, self.spacing do
        for x=minx, maxx, self.spacing do
            local hash = self:hash(x, y)
            callback(x, y, hash, self:get(x, y))
        end
    end
end

function StaticBoxGrid:hash(x, y)
    return math.floor(x / self.spacing) * (self.spacing * 8) + math.floor(y / self.spacing)
end

function StaticBoxGrid:get(x, y)
    return self.buckets[self:hash(x, y)] or self.empty
end
-- End Dynamic ----------------------------------------------------------------



-- ----------------------------------------------------------------------------
-- Moving AABB Box ------------------------------------------------------------
-- ----------------------------------------------------------------------------
local MovingBox = class(StaticBox)
function MovingBox:new(x, y, w, h)
    StaticBox.new(self, x, y, w, h)
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

    game.graphics.setColor(0, 255, 0)
    game.graphics.rectangle(x, y, sx, sy)

    game.graphics.setColor(0, 0, 255)
    game.graphics.line(cx, cy, cx + vx / vl * 10, cy + vy / vl * 10, 2)
end
-- End Moving -----------------------------------------------------------------



-- ----------------------------------------------------------------------------
-- Dynamic AABB Box -----------------------------------------------------------
-- ----------------------------------------------------------------------------
local DynamicBox = class(StaticBox)
function DynamicBox:new(x, y, w, h)
    StaticBox.new(self, x, y, w, h)

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

function DynamicBox:setPosition(x, y) 
    self.pos.x = math.floor(x + 0.5)
    self.pos.y = math.floor(y + 0.5)
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

    game.graphics.setColor(255, 255, 0)
    game.graphics.rectangle(x, y, sx, sy)

    game.graphics.setColor(0, 0, 255)
    game.graphics.line(cx, cy, cx + vx / vl * 10, cy + vy / vl * 10, 2)

    game.graphics.setColor(0, 0, 255)
    if self.contactSurface.down then
        game.graphics.line(x, y + sy, x + sx, y + sy, 2)
    end

    if self.contactSurface.up then
        game.graphics.line(x, y, x + sx, y, 2)
    end

    if self.contactSurface.left then
        game.graphics.line(x, y, x, y + sy, 2)
    end

    if self.contactSurface.right then
        game.graphics.line(x + sx, y, x + sx, y  + sy, 2)
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
        if b.max.x < a.min.x then return false, nil, nil end
        if b.max.x > a.min.x then
            outTime = math.min((a.min.x - b.max.x) / v.x, outTime)
        end

        if a.max.x < b.min.x then
            overlapsTime.x = (a.max.x - b.min.x) / v.x
            hitTime = math.max(overlapsTime.x, hitTime)
        end

    elseif v.x > 0 then
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
        if b.max.y < a.min.y then return false, nil, nil end
        if b.max.y > a.min.y then
            outTime = math.min((a.min.y - b.max.y) / v.y, outTime)
        end

        if a.max.y < b.min.y then
            overlapsTime.y = (a.max.y - b.min.y) / v.y
            hitTime = math.max(overlapsTime.y, hitTime)
        end

    elseif v.y > 0 then
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
            if a.max.y == b.min.y and b.blocks.up then
                self.contactSurface.down = b

            elseif a.min.y == b.max.y and b.blocks.down then
                self.contactSurface.up = b
            end
        end

        if a.min.y < b.max.y and a.max.y > b.min.y then
            if a.max.x == b.min.x and b.blocks.right then
                self.contactSurface.right = b

            elseif a.min.x == b.max.x and b.blocks.left then
                self.contactSurface.left = b
            end
        end

        -- in case we're stuck make sure push us out
        local pushVel = {
            x = 0,
            y = 0
        }

        local acy = a.min.y + a.size.y / 2
        local bcy = b.min.y + b.size.y / 2

        local acx = a.min.x + a.size.x / 2
        local bcx = b.min.x + b.size.x / 2

        if math.abs(acx - bcx) < (a.size.x + b.size.x) / 2 and math.abs(acy - bcy) < (a.size.y + b.size.y) / 2 then

            if acy < bcy then
                pushVel.y = b.min.y - a.max.y

            else
                pushVel.y = b.max.y - a.min.y
            end

            if acx < bcx then
                pushVel.x = b.min.x - a.max.x

            else
                pushVel.x = b.max.x - a.min.x
            end

            -- handle non blocking edges
            if pushVel.x < 0 and not b.blocks.right and v.x >= 0 then
                pushVel.x = 0

            elseif pushVel.x > 0 and not b.blocks.right and v.x <= 0 then
                pushVel.x = 0
            end

            if pushVel.y < 0 and not b.blocks.down and v.y >= 0 then
                pushVel.y = 0

            elseif pushVel.y > 0 and not b.blocks.up and v.y <= 0 then
                pushVel.y = 0
            end

            -- now choose the minium / maximum of the push / out values
            -- to resolve the stuck state in the "best" way
            if math.abs(pushVel.y) < math.abs(pushVel.x) then
                outVel.y = outVel.y + pushVel.y

            elseif math.abs(pushVel.x) > math.abs(pushVel.y) then
                outVel.x = outVel.x + pushVel.x

            else
                outVel.y = outVel.y + pushVel.y
                outVel.x = outVel.x + pushVel.x
            end

        end

    end

    -- in case the block isn't blocking in specific directions+
    -- reset the out velocity

    -- up / down
    if outVel.y > 0 and not b.blocks.down and v.y >= 0 then
        outVel.y = 0

    elseif not b.blocks.down and v.y >= 0 then
        outVel.y = 0

    elseif outVel.y < 0 and not b.blocks.up and v.y <= 0 then
        outVel.y = 0

    elseif not b.blocks.up and v.y <= 0 then
        outVel.y = 0
    end

    -- left / right
    if outVel.x > 0 and not b.blocks.left and v.x >= 0 then
        outVel.x = 0

    elseif not b.blocks.left and v.x >= 0 then
        outVel.x = 0

    elseif outVel.x < 0 and not b.blocks.right and v.x >= 0 then
        outVel.x = 0

    elseif not b.blocks.right and v.x <= 0 then
        outVel.x = 0
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
-- End Dynamic ----------------------------------------------------------------



-- ----------------------------------------------------------------------------
-- Box Manager ----------------------------------------------------------------
-- ----------------------------------------------------------------------------
local BoxManager = class()

function BoxManager:new()
    self.dynamics = {}
    self.movings = {}
    self.staticGrid = StaticBoxGrid(64)
end

function BoxManager:add(box)
    if box:is_a(DynamicBox) then
        table.insert(self.dynamics, box)

    elseif box:is_a(MovingBox) then
        table.insert(self.movings, box)

    else
        self.staticGrid:add(box)
    end
end

function BoxManager:remove(box)
    -- TODO oh noes
    if box:is_a(DynamicBox) then

    else

    end
end

function BoxManager:update(dt)
    --table.sort(self.dynamics, function(a, b)
        --if a.pos.y > b.pos.y then
            --return true

        --elseif b.pos.y < a.pos.y then
            --return false
        --end
    --end)

    for i=1, #self.dynamics do
        self.dynamics[i]:beforeUpdate(dt)
    end

    -- collide all dynamics against all statics
    for i=1, #self.dynamics do

        local box = self.dynamics[i]

        -- now check all static dynamics in the same area
        local statics = self.staticGrid:get(box.pos.x, box.pos.y)
        for e=1, #statics do

            local col, vel, normal = box:sweep(statics[e])

            if col then
                box:onCollision(statics[e], vel, normal)
            end

        end

    end

    for i=1, #self.dynamics do

        local box = self.dynamics[i]

        -- now check all static dynamics in the same area
        for e=1, #self.movings do

            local col, vel, normal = box:sweep(self.movings[e])

            if col then
                box:onCollision(self.movings[e], vel, normal)
            end

        end

    end

    -- collide all dynamics with each other
    -- the problematic part here is to know
    -- that the relative velocities of the boxes are in play
    -- so we need to make sure that a box which is hit, checks 
    --for i=1, #self.dynamics do

        --local box = self.dynamics[i]
        --local col, vel, normal = self:collideBox(box)

        --if col then
            --box:onCollision(col, vel, normal)
        --end

    --end
    
    -- now update all dynamic and movings boxes 
    for i=1, #self.dynamics do
        self.dynamics[i]:update(dt)
    end

    for i=1, #self.movings do
        self.movings[i]:update(dt)
    end
end

function BoxManager:collideBox(box, ignore)
    for e=1, #self.dynamics do

        local other = self.dynamics[e]
        if other ~= box then

            local col, vel, normal = box:sweep(other)
            if col then
                
                --if other ~= ignore then
                    --local ocol, ovel, onormal = self:collideBox(other, box)
                    --print(vel.y, ovel.y)
                    --vel.y = vel.y - ovel.y * 2
                --end

                return other, vel, normal

            end

        end

    end
end

function BoxManager:eachIn(x, y, mx, my, callback)
    self.staticGrid:eachIn(x, y, mx, my, function(x, y, hash, statics)
        for e=1, #statics do
            callback(statics[e])
        end
    end)

    for i=1, #self.movings do
        if self.movings[i]:within(x, y, mx, my) then
            callback(self.movings[i])
        end
    end

    for i=1, #self.dynamics do
        if self.dynamics[i]:within(x, y, mx, my) then
            callback(self.dynamics[i])
        end
    end
end

function BoxManager:draw(x, y, mx, my)
    self:eachIn(x, y, mx, my, function(box)
        box:draw()
    end)
end
-- End Manager ----------------------------------------------------------------



return {
    Static= StaticBox,
    Dynamic= DynamicBox,
    Moving= MovingBox,
    Manager = BoxManager
}


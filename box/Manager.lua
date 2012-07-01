local DynamicBox = require('Dynamic', ...)
local StaticBox = require('Static', ...)
local MovingBox = require('Moving', ...)

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

function BoxManager:eachIn(min, max, callback)

    self.staticGrid:eachIn(min, max, function(x, y, hash, statics)
        for e=1, #statics do
            callback(statics[e])
        end
    end)

    for i=1, #self.movings do
        if self.movings[i]:within(min, max) then
            callback(self.movings[i])
        end
    end

    for i=1, #self.dynamics do
        if self.dynamics[i]:within(min, max) then
            callback(self.dynamics[i])
        end
    end

end

function BoxManager:draw(min, max)
    self:eachIn(min, max, function(box)
        box:draw()
    end)
end

return BoxManager


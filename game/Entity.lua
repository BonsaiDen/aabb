Entity = class(DynamicBox)
function Entity:new(pos, size)

    DynamicBox.new(self, pos, size)

    self.gravity = 0 
    self.gravityAcceleration = 0
    self.jumpForce = 0
    self.jumpDecelaration = 0
    self.movement = { x = 0, y = 0} 

    self.maxFallSpeed = 3
    self:fall(self.maxFallSpeed, 0.5)

end

function Entity:jump(height, seconds)

    -- calculate the values for a jump
    local steps = seconds / (1.0 / 60)
    local force = height * (1.0 / steps) * 2.0
    self.jumpDecelaration = force / math.max(steps - 1.0, 1.0)
    self.jumpForce = -force

    -- check for platform and correct jump force to include platform y velocity
    if self.contactSurface.down and self.contactSurface.down:is_a(MovingBox) then
        self.jumpForce = self.jumpForce + self.contactSurface.down.vel.y
    end

end

function Entity:fall(maxSpeed, seconds)
    local steps = seconds / (1.0 / 60)
    self.gravityAcceleration = maxSpeed / (math.max(steps - 1, 0.1));
end


function Entity:update(dt)
    
    DynamicBox.update(self, dt)

    -- jump forces and gravity are handles differently
    -- this makes the whole system easier and more friendly to gameplay tweaking
    if self.jumpForce < self.maxFallSpeed and self.jumpDecelaration ~= 0 then
        self.jumpForce = self.jumpForce + self.jumpDecelaration
        self.vel.y = (self.movement.y * dt) + self.jumpForce
        self.gravity = self.jumpForce

    else
        
        -- check whether we're falling
        if not self.contactSurface.down then

            self.gravity = self.gravity + self.gravityAcceleration
            if self.gravity > self.maxFallSpeed then
                self.gravity = self.maxFallSpeed
            end

        else

            self.gravity = 0

            -- check for platforms and make the entity move downwards with them
            if self.contactSurface.down:is_a(MovingBox) then
                self.gravity = self.contactSurface.down.vel.y
            end

        end

        self.vel.y = (self.movement.y * dt) + self.gravity 

    end

    -- check for platform and x velocity to include platform x velocity
    self.vel.x = (self.movement.x * dt)
    if self.contactSurface.down and self.contactSurface.down:is_a(MovingBox) then

        local mx = self.contactSurface.down.vel.x
        if self.vel.x == 0 or (self.vel.x > 0 and mx > 0) or (self.vel.x < 0 and mx < 0) then
            self.vel.x = (self.movement.x * dt) + mx
        end
        
    end

end


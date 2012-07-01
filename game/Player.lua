require 'game/Animation'
require 'game/ImageSheet'

Player = class(DynamicBox)

function Player:new(pos, size)

    DynamicBox.new(self, pos, size)

    self.gravity = 0 
    self.gravityAcceleration = 0
    self.jumpForce = 0
    self.jumpDecelaration = 0
    self.movement = { x = 0, y = 0} 

    self.maxFallSpeed = 3
    self:fall(self.maxFallSpeed, 0.5)

    self.animations = {
        idle = Animation({ 1, 2, 1, 2, 1, 3, 1, 2, 1, 2, 1 }, { 2.5, 0.15, 2, 0.1, 3, 0.6, 2, 0.10, 0.25, 0.10, 4 }, true),
        run = Animation({ 9, 10, 11, 12 }, { 0.035, 0.06, 0.045, 0.06 }, true),
        jump = Animation({ 25, 26 }, { 0.25, 1 }),
        fall = Animation({ 27, 28 }, { 0.25, 1 })
    }

    self.animation = self.animations.idle

end


function Player:update(dt)

    self.animation:update(dt)

    if love.keyboard.isDown('s') then
        if self.contactSurface.down then
            self.contactSurface.down = nil
            self.animations.jump:reset()
            self.animation = self.animations.jump
            self:jump(30, 0.4)
        end
    end

    if self.contactSurface.up then
        self.jumpForce = 0
        self.gravity = 0
    end

    if love.keyboard.isDown('a') and not self.contactSurface.left then
        self.movement.x = -64
        self.direction = -1

    elseif love.keyboard.isDown('d') and not self.contactSurface.right then
        self.movement.x = 64
        self.direction = 1

    else
        self.animations.run:reset()
        self.movement.x = 0
    end

    if self.contactSurface.down then
        self.animations.fall:reset()
        self.gravity = 0

        if self.movement.x ~= 0 then
            self.animation = self.animations.run

        else
            self.animation = self.animations.idle
        end

    elseif self.vel.y > 0 then
        self.animation = self.animations.fall
    end

    DynamicBox.update(self, dt)

    -- jump forces and gravity are handles differently
    -- this makes the whole system easier and more friendly to gameplay
    -- tweaking
    if self.jumpForce < self.maxFallSpeed and self.jumpDecelaration ~= 0 then
        self.jumpForce = self.jumpForce + self.jumpDecelaration
        self.vel.y = (self.movement.y * dt) + self.jumpForce
        self.gravity = self.jumpForce

    else
        
        if not self.contactSurface.down then

            self.gravity = self.gravity + self.gravityAcceleration
            if self.gravity > self.maxFallSpeed then
                self.gravity = self.maxFallSpeed
            end

        end

        self.vel.y = (self.movement.y * dt) + self.gravity 

    end

    self.vel.x = (self.movement.x * dt)

end

function Player:jump(height, seconds)
    local steps = seconds / (1.0 / 60)
    local force = height * (1.0 / steps) * 2.0
    self.jumpDecelaration = force / math.max(steps - 1.0, 1.0)
    self.jumpForce = -force
end


function Player:fall(maxSpeed, seconds)
    local steps = seconds / (1.0 / 60)
    self.gravityAcceleration = maxSpeed / (math.max(steps - 1, 0.1));
end

function Player:draw()
    local frame = self.animation:getFrame()
    game.images.player:drawTile(frame, { x = math.round(self.pos.x - 3), y = math.round(self.pos.y - 7) }, self.direction == 1)
    DynamicBox.draw(self)
end

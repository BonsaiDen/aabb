require 'class'
require 'box'


-- Simple 2D Entity System ----------------------------------------------------
Entity = class(DynamicBox)

function Entity:new(pos, size)

    DynamicBox.new(self, pos, size)

    self.gravity = 0 -- the current gravtiational value being applied
    self.gravityStep = 190 -- the 
    self.acceleration = { x = 0, y = 0 } -- acceleration per second
    self.movement = { x = 0, y = 0} -- static movement constant to be applied per second
    self.velocity = { x = 0, y = 0 } -- actual, final velocity of the entity per second

end

function Entity:update(dt)

    DynamicBox.update(self, dt)

    if not self.hitSurface.down then
        self.gravity = self.gravity + (self.gravityStep * dt)
    end

    self.velocity.x = self.velocity.x + (self.acceleration.x * dt)
    self.velocity.y = self.velocity.y + (self.acceleration.y * dt)

    self.vel.x = self.velocity.x + (self.movement.x * dt)
    self.vel.y = self.velocity.y + (self.movement.y * dt) + (self.gravity * dt)

end


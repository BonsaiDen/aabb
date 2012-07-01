require 'game/Animation'
require 'game/ImageSheet'
require 'game/Entity'

Player = class(Entity)
function Player:new(pos, size)

    Entity.new(self, pos, size)

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

    if self.contactSurface.up then
        self.jumpForce = 0
        self.gravity = 0
    end

    if love.keyboard.isDown('a') then
        self.direction = -1

    elseif love.keyboard.isDown('d') then
        self.direction = 1
    end

    if love.keyboard.isDown('a') and not self.contactSurface.left then
        self.movement.x = -64

    elseif love.keyboard.isDown('d') and not self.contactSurface.right then
        self.movement.x = 64

    else
        self.animations.run:reset()
        self.movement.x = 0
    end

    if self.contactSurface.down then
        self.animations.fall:reset()

        if self.movement.x ~= 0 then
            self.animation = self.animations.run

        else
            self.animation = self.animations.idle
        end

    elseif self.vel.y > 0 then
        self.animation = self.animations.fall
    end

    if love.keyboard.isDown('s') then
        if self.contactSurface.down then
            self.animations.jump:reset()
            self.animation = self.animations.jump
            self:jump(30, 0.4)
        end
    end

    Entity.update(self, dt)

end

function Player:draw()
    local frame = self.animation:getFrame()
    game.images.player:drawTile(frame, { x = math.round(self.pos.x - 3), y = math.round(self.pos.y - 7) }, self.direction == 1)
    DynamicBox.draw(self)
end


require 'game'
box = require 'box'
require 'game.Player'

function game.load(arg)

    game.graphics.setBackgroundColor(64, 64, 64)

    game.manager = box.Manager()
    game.platform = box.Moving(100, 130,  50, 9)
    game.platform.blocks.down = false
    game.platform.blocks.right = false
    game.platform.blocks.left = false
    game.platform.vel.y = 0.5

    game.graphics.newImage('player', 'game/player.png')
    game.graphics.newSheet('player', 'player', 8, 8)
    game.player = Player(35, 120, 10, 9)

    game.manager:add(box.Static(0, 140, 140, 50))

    local c = box.Static( 50, 120, 60, 1)
    c.blocks.down = false
    c.blocks.right = false
    c.blocks.left = false

    game.manager:add(c)

    game.manager:add(box.Static(150, 160, 100, 50))

    game.manager:add(box.Static(200, 50, 60, 200))

    game.manager:add(box.Static(0, 20, 30, 4))

    game.manager:add(box.Static(0, 100, 30, 40))

    game.manager:add(box.Static(200, 0, 50, 50))

    game.manager:add(box.Static(0, 280, 320, 4))

    --game.manager:add(game.platform)
    game.manager:add(game.player)

end

function game.update(dt, time)

    if game.mouse.isDown('l') then
        local x, y = game.mouse.getPosition()
        game.player:setPosition(x, y)
    end

    if game.keyboard.isDown('return') then
        game.quit()
    end

    if not game.isPaused() then
        game.manager:update(dt)
    end

end

function game.draw()
    game.manager:draw(0,  0, 320, 288)
end


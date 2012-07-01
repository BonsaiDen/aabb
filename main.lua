require 'conf'
require 'class'
box = require 'box'
require 'game.Player'


-- Global Game State ----------------------------------------------------------
function love.load(arg)
    love.graphics.setColorMode('replace')
    love.graphics.setDefaultImageFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')
    love.graphics.setLineWidth(1 / game.scale)

    love.graphics.setBackgroundColor(128, 128, 128)

    game.manager = box.Manager()

    game.player = Player({ x = 35, y = 120}, { x = 10, y = 9})
    game.platform = box.Moving({ x = 100, y = 130}, { x = 50, y = 9})
    game.platform.blocks.down = false
    game.platform.blocks.right = false
    game.platform.blocks.left = false
    game.platform.vel.y = 0.5

    game.images.player = ImageSheet(love.graphics.newImage('game/player.png'), 8, 8)

    game.manager:add(box.Static({ x = 0, y = 140 }, { x = 140, y = 50 }))

    local c = box.Static({ x = 50, y = 120 }, { x = 60, y = 1 })
    c.blocks.down = false
    c.blocks.right = false
    c.blocks.left = false

    game.manager:add(c)

    game.manager:add(box.Static({ x = 150, y = 160 }, { x = 100, y = 50 }))

    game.manager:add(box.Static({ x = 200, y = 50 }, { x = 60, y = 200 }))

    game.manager:add(box.Static({ x = 0, y = 20 }, { x = 30, y = 4 }))

    game.manager:add(box.Static({ x = 0, y = 100 }, { x = 30, y = 40 }))

    game.manager:add(box.Static({ x = 200, y = 0 }, { x = 50, y = 50 }))

    game.manager:add(box.Static({ x = 0, y = 280 }, { x = 320, y = 4 }))

    --game.manager:add(game.platform)
    game.manager:add(game.player)
end

function love.update(dt)
    if love.mouse.isDown('l') then
        local x, y = love.mouse.getPosition()
        game.player:setPosition({ x = x / game.scale, y = y / game.scale })
    end

    if love.keyboard.isDown('return') then
        love.event.push('quit')
    end

    game.manager:update(dt)
end

function love.draw()
    love.graphics.scale(game.scale, game.scale)
    love.graphics.setColor(255, 255, 255)
    game.manager:draw({ x = 0, y = 0}, { x = 320 , y = 288})
end



require 'conf'
require 'class'
require 'box'
require 'game/Player'

function math.round(num)
    return math.floor(num + 0.5)
end

function math.sign(x)
   if x < 0 then
        return -1
   elseif x > 0 then
        return 1
   else
        return 0
   end
end



game.player = Player({ x = 20, y = 0}, { x = 10, y = 9})


-- Global Game State ----------------------------------------------------------
manager = BoxManager()

function love.load(arg)

    love.graphics.setColorMode('replace')
    love.graphics.setDefaultImageFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')
    love.graphics.setLineWidth(1 / game.scale)

    love.graphics.setBackgroundColor(128, 128, 128)

    game.images.player = ImageSheet(love.graphics.newImage('game/player.png'), 8, 8)

    manager:add(StaticBox({ x = 0, y = 140 }, { x = 140, y = 50 }))

    manager:add(StaticBox({ x = 150, y = 160 }, { x = 100, y = 50 }))

    manager:add(StaticBox({ x = 200, y = 50 }, { x = 60, y = 200 }))

    manager:add(StaticBox({ x = 0, y = 20 }, { x = 30, y = 4 }))

    manager:add(StaticBox({ x = 0, y = 100 }, { x = 30, y = 40 }))

    manager:add(StaticBox({ x = 200, y = 0 }, { x = 50, y = 50 }))

    manager:add(StaticBox({ x = 0, y = 280 }, { x = 320, y = 4 }))

    manager:add(game.player)

end

function love.update(dt)
    manager:update(dt)
end

function love.draw()
    love.graphics.scale(game.scale, game.scale)
    love.graphics.setColor(255, 255, 255)
    manager:draw({ x = 0, y = 0}, { x = 320 , y = 288})
end



require 'conf'
require 'entity'

function math.round(num)
    return math.floor(num + 0.5)
end

blu = Entity({ x = 20, y = 4}, { x = 16, y = 16})
foo = Entity({ x = 20, y = 30}, { x = 20, y = 20})
bar = Entity({ x = 20, y = 60}, { x = 20, y = 20})
toz = Entity({ x = 20, y = 90}, { x = 20, y = 20})


-- Global Game State ----------------------------------------------------------
manager = BoxManager()

function love.load(arg)

    love.graphics.setColorMode('replace')
    love.graphics.setDefaultImageFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')
    love.graphics.setLineWidth(1 / game.scale)

    manager:add(StaticBox({ x = 0, y = 140 }, { x = 140, y = 50 }))
    manager:add(StaticBox({ x = 146, y = 50 }, { x = 60, y = 200 }))

    manager:add(blu)
    manager:add(foo)
    manager:add(bar)
    manager:add(toz)
    --manager:addEntity(mover)


end

function love.draw()
    love.graphics.scale(game.scale, game.scale)
    love.graphics.setColor(255, 255, 255)
    manager:draw({ x = 0, y = 0}, { x = 320 , y = 288})
end

function love.update(dt)
    manager:update(dt)
end

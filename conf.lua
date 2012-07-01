game = {
    scale = 3,
    images = {},
    sounds = {}
}

function math.round(num)
    return math.floor(num + 0.5)
end

function game.drawBox(x, y, w, h)
    love.graphics.rectangle('line', math.round(x) + 1 / game.scale,
                                    math.round(y),
                                    w - 1 / game.scale,
                                    h - 1 / game.scale)
end


function game.drawLine(x, y, x2, y2, width)
    width = width or 1
    love.graphics.setLineWidth(width / game.scale)
    love.graphics.line(math.round(x), math.round(y),
                        math.round(x2), math.round(y2))

    love.graphics.setLineWidth(1 / game.scale)
end

function love.conf(t)
    t.title = 'AABB'
    t.screen.width = 320 * game.scale
    t.screen.height = 288 * game.scale
    t.screen.fsaa = 0
    t.modules.joystick = false
    t.modules.physics = false
end


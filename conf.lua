game = {
    scale = 2,
    images = {},
    sounds = {}
}

function game.drawBox(x, y, w, h)
    love.graphics.rectangle('line', math.round(x) + 1 / game.scale,
                                    math.round(y),
                                    w - 1 / game.scale,
                                    h - 1 / game.scale)
end


function love.conf(t)
    t.title = 'AABB'
    t.screen.width = 320 * game.scale
    t.screen.height = 288 * game.scale
    t.screen.fsaa = 0
    t.modules.joystick = false
    t.modules.physics = false
end


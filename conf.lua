game = {
    scale = 3
}

function love.conf(t)
    t.title = 'AABB'
    t.screen.width = 320 * game.scale
    t.screen.height = 288 * game.scale
    t.screen.fsaa = 0
    t.modules.joystick = false
    t.modules.physics = false
end


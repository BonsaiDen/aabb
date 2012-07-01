require 'class'

-- Patch Lua ------------------------------------------------------------------
function math.round(num)
    return math.floor(num + 0.5)
end


-- ----------------------------------------------------------------------------
-- Game Abstraction -----------------------------------------------------------
-- ----------------------------------------------------------------------------
game = {
    _scale = 3,
    _images = {},
    _sheets = {},
    _sounds = {},
    _time = 0,
    _isPaused = false,

    graphics = {},
    keyboard = {},
    mouse = {}
}

function game.load(arg) end
function game.update(dt) end
function game.draw() end

function game.quit()
    love.event.push('quit')
end

function game.graphics.getScale()
    return game._scale
end

function game.getTime()
    return game._time
end

function game.isPaused()
    return game._isPaused
end

function game.getWidth()
end

function game.getHeight()
end


-- ----------------------------------------------------------------------------
-- Love hooks -----------------------------------------------------------------
-- ----------------------------------------------------------------------------
function love.load(arg)

    love.graphics.setColorMode('replace')
    love.graphics.setDefaultImageFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')
    love.graphics.setLineWidth(1 / game._scale)

    game.load(arg)

end

function love.update(dt)


    if game.keyboard.wasHit('p') then
        if game._isPaused then
            game._isPaused = false
        else
            game._isPaused = true
        end
    end

    if not game._isPaused then
        game._time = game._time + dt
        game.update(dt, game._time)

    else
        game.update(0, game._time)
    end

end

function love.draw()
    love.graphics.scale(game._scale, game._scale)
    game.draw()
end



-- ----------------------------------------------------------------------------
-- Graphics -------------------------------------------------------------------
-- ----------------------------------------------------------------------------
function game.graphics.newImage(key, file)
    game._images[key] = love.graphics.newImage(file)
end

function game.graphics.getImage(key)
    return game._images[key]
end

function game.graphics.setColor(r, g, b)
    love.graphics.setColor(r, g, b)
end

function game.graphics.setBackgroundColor(r, g, b)
    love.graphics.setBackgroundColor(r, g, b)
end

function game.graphics.rectangle(x, y, w, h)
    love.graphics.rectangle('line', math.round(x) + 1 / game._scale,
                                    math.round(y), w - 1 / game._scale, h - 1 / game._scale)
end

function game.graphics.line(x, y, x2, y2, width)
    width = width or 1
    love.graphics.setLineWidth(width / game._scale)
    love.graphics.line(math.round(x), math.round(y),
                        math.round(x2), math.round(y2))

    love.graphics.setLineWidth(1 / game._scale)
end



ImageSheet = class()
function ImageSheet:new(image, rows, cols)

    -- Properties
    self.image = image
    self.size = { w = image:getWidth(), h = image:getHeight()}
    self.layout = {
        cols = cols,
        rows = rows,
        w = self.size.w / cols,
        h = self.size.h / rows
    }

    -- Setup quads
    self.quads = {}
    for y=0,self.layout.rows - 1 do
        for x=0, self.layout.cols - 1 do
            local index = y * self.layout.rows + x
            self.quads[index + 1] = love.graphics.newQuad(x * self.layout.w, y * self.layout.h, self.layout.w, self.layout.h, self.size.w, self.size.h)
        end
    end

end

function ImageSheet:drawTile(index, at, flipX, flipY)
    love.graphics.drawq(self.image, self.quads[index], 
                        at.x + (flipX and self.layout.w or 0),
                        at.y + (flipY and self.layout.h or 0),
                        0, flipX and -1 or 1, flipY and -1 or 1)
end

function game.graphics.newSheet(key, image, rows, cols)

    if type(image) == 'string' then
        image = game.graphics.getImage(key)
    end

    game._sheets[key] = ImageSheet(image, rows, cols)
    return game._sheets[key]

end

function game.graphics.getSheet(key)
    return game._sheets[key]
end




-- ----------------------------------------------------------------------------
-- Keyboard -------------------------------------------------------------------
-- ----------------------------------------------------------------------------
game._keyboardState = {}
game.keyboard.wasHit = function(key)
    
    if not game._keyboardState[key] then

        local pressed = false
        game._keyboardState[key] = function()
            if love.keyboard.isDown(key) then

                if not pressed then
                    pressed = true
                    return true
                else
                    return false
                end

            else
                pressed = false
                return false
            end

        end

    end

    return game._keyboardState[key]()

end

game.keyboard.isDown = function(key)
    return love.keyboard.isDown(key)
end


-- ----------------------------------------------------------------------------
-- Mouse ----------------------------------------------------------------------
-- ----------------------------------------------------------------------------
game.mouse.isDown = function(button)
    return love.mouse.isDown(button)
end

game.mouse.getPosition = function()
    local x, y = love.mouse.getPosition()
    x = math.round(x / game._scale)
    y = math.round(y / game._scale)
    return x, y 
end


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


Animation = class()

function Animation:new(frames, lengths, loop)

    self.index = 1
    self.timeOffset = 0
    self.paused = false
    self.looping = loop or false

    self.frames = frames
    self.frameOffsets = {}

    local offset = 0
    for i=1, #lengths do
        offset = offset + lengths[i]
        self.frameOffsets[i] = offset
    end

end

function Animation:reset()
    self.running = true
    self.timeOffset = 0
    self.index = 1
end

function Animation:getFrame()
    return self.frames[self.index]
end

function Animation:pause()
    self.paused = true
end

function Animation:resume()
    self.paused = false
end

function Animation:update(dt)

    if not self.paused then
        self.timeOffset = self.timeOffset + dt
    end

    local found = -1
    for i=self.index, #self.frameOffsets do
        if self.frameOffsets[i] >= self.timeOffset then
            found = i
            break
        end
    end

    if found == -1 then
        if self.looping then
            self.index = 1
            self.timeOffset = 0
        end

    else
        self.index = found
    end

end

--animation = Animation({ 0, 1, 2, 3, 4, 5 }, { 0.25, 0.5, 1, 1.5, 2.0, 2.5 }, true)


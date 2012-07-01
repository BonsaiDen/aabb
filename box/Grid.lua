local StaticBoxGrid = class()
function StaticBoxGrid:new(spacing)

    -- this should be bigger then the maximum square size of any dynamic object
    self.spacing = spacing or 64 
    self.buckets = {}
    self.empty = {}

    self.boxes = {}

end

function StaticBoxGrid:add(box)

    table.insert(self.boxes, box)

    self:eachIn(box.min, box.max, function(x, y, hash)
    
        if not self.buckets[hash] then
            self.buckets[hash] = {}
        end

        table.insert(self.buckets[hash], box)

    end)

end

function StaticBoxGrid:eachIn(min, max, callback)

    local minx = math.floor(min.x / self.spacing) * self.spacing - self.spacing
    local maxx = math.floor(max.x / self.spacing) * self.spacing + self.spacing

    local miny = math.floor(min.y / self.spacing) * self.spacing - self.spacing
    local maxy = math.floor(max.y / self.spacing) * self.spacing + self.spacing

    for y=miny, maxy, self.spacing do
        for x=minx, maxx, self.spacing do
            local hash = self:hash(x, y)
            callback(x, y, hash, self:get(x, y))
        end
    end

end

function StaticBoxGrid:hash(x, y)
    return math.floor(x / self.spacing) * (self.spacing * 8) + math.floor(y / self.spacing)
end

function StaticBoxGrid:get(x, y)
    return self.buckets[self:hash(x, y)] or self.empty
end

return StaticBoxGrid

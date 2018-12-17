Object = require 'helpers/classic'

Tile = Object:extend()



function Tile:new(x, y, width, height, quad, tileId, layer)
  self.name = 'Tile'
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.quad = quad
  self.tileId = tileId
  self.isVisible = true
  self.layer = layer
  -- add tile to the world for collision detection
  world:add(self, self.x, self.y, self.width, self.height)

end

function Tile:update(self, dt)
  -- what to do here?
  -- print( ('Original - (%d, %d)'):format(self.x,self.y) )
  -- print( ('Camera - (%d, %d)'):format(camera:toCameraCoords(self.x,self.y)) )
end


function Tile:draw(self, tilesheetsrc)
  -- animate based on tile type
  if self.isVisible then
    love.graphics.draw(tilesheetsrc, self.quad, self.x, self.y)
    -- draw line around to show collision box 
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
  end
end

function Tile:destroy(self)
  world:remove(self)
end
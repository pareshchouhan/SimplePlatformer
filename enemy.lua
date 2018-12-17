Object = require('./helpers/classic')

Enemy = Object:extend()

function Enemy:new(x, y, width, height, quad, tileId, layer)
  self.name = 'Enemy'
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


function Enemy:update(self, dt)
  -- move left right and randomly fire projectiles at user
  
end

function Enemy:draw(self, enemysheetsrc)
  if self.isVisible then
    love.graphics.draw(enemysheetsrc, self.quad, self.x, self.y)
  end
end
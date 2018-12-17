Object = require('./helpers/classic')

Bullet = Object:extend()

local bulletImage = love.graphics.newImage('resources/player/bullet1.png')

function Bullet:new(x, y, direction)
  self.name = 'Bullet'
  self.startX = x
  self.startY = y
  self.x = x
  self.y = y
  self.xVelocity = 200
  self.direction = direction
  self.scale = 0.05
  self.width, self.height = bulletImage:getDimensions()
  world:add(self, x, y, self.width * self.scale, self.height * self.scale)
end

function Bullet:filter(other)
  local kind = other.name
  if kind == 'Enemy' then
    other.isVisible = false
    return 'touch'
  end
  return 'cross'
end

function Bullet:update(self, dt)
  -- self.x = self.x + self.xVelocity * dt
  -- self.y = self.y
  
  local goalX = self.x + self.xVelocity * self.direction * dt
  local goalY = self.y
  local actualX, actualY, cols, len = world:move(self, goalX, goalY, self.filter)
  self.x = actualX
  self.y = self.y
  --[[
  -- check collisions
  self.x = self.x + actualX 
  self.y = self.y + actualY
  if len > 0 then
    for item = 1, len do
      if cols[item].other.name == 'Enemy' then
        -- self.isVisible = false
        world:remove(self)
      end
    end
  end
  -- self.xVelocity = self.xVelocity +  self.direction * dt
  ]]--
end

function Bullet:draw(self)
  local originOffsetX = 0
  if self.direction == -1 then
    originOffsetX = self.width
  end
  love.graphics.rectangle('line', self.x, self.y, self.width * self.scale, self.height * self.scale, 0, self.direction, 1, originOffsetX, 0)
  -- love.graphics.draw(bulletImage, self.x, self.y, 0, self.scale * self.direction , self.scale, originOffsetX, 0)
  love.graphics.draw(bulletImage, self.x, self.y, 0, self.direction * self.scale, self.scale, originOffsetX, 0)

end

-- destroy code.
function Bullet:destroy(self)
  world:remove(self)
end


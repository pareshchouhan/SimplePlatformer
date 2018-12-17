Object = require('./helpers/classic')

Cursor = Object:extend()

function Cursor:new()
  self.x = 0
  self.y = 0
  self.radius = 25
  self.speed = 100
end

function Cursor:update(self, dt)
  local mouse_x, mouse_y = camera:getMousePosition()
  -- angle = math.atan2(mouse.y - circle.y, mouse.x - circle.x) 
  self.x = mouse_x
  self.y = mouse_y
  
end

function Cursor:draw(self)
  love.graphics.circle('line', self.x, self.y, self.radius)
end
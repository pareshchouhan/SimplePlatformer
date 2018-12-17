Object = require 'helpers/classic'
tick = require 'helpers/tick'
anim8 = require 'helpers/anim8'

Player = Object:extend()

require('bullet');

local bulletFired = false

local jumpSound = love.audio.newSource('resources/sfx/jump.mp3', 'static')
local gemCollect = love.audio.newSource('resources/sfx/gem_collect.mp3', 'static')
local heartCollect = love.audio.newSource('resources/sfx/heart_collect.mp3', 'static')

local playerShader

local dustEmitter

jumpSound:setVolume(0.8)
gemCollect:setVolume(0.8)
heartCollect:setVolume(1.5)

function Player:new(x, y)
  self.name = 'Player'
  self.x = x or 0
  self.y = y or 0
  self.gravity = 200
  self.xVelocity = 0
  self.yVelocity = 0
  self.acceleration = 300
  self.friction = 30
  self.maxSpeed = 600
  self.isJumping = false
  self.isGrounded = false
  self.hasReachedMax = false
  self.jumpAcceleration = 6000
  self.jumpMaxSpeed = 300
  self.isFacingLeft = 1
  self.width = 67
  self.height = 92
  playerShader = love.graphics.newShader([[
    // extern vec2 abberationVector;
    /*
    vec4 effect(vec4 color, Image currentTexture, vec2 texCoords, vec2 screenCoords){
      vec4 finalColor = vec4(1);
      finalColor.r = Texel(currentTexture, texCoords.xy + abberationVector).r;
      finalColor.g = Texel(currentTexture, texCoords.xy).g;
      finalColor.b = Texel(currentTexture, texCoords.xy - abberationVector).b;
      return finalColor;
    }
    */
  vec4 effect(vec4 color, Image currentTexture, vec2 texCoords, vec2 screenCoords){
    float dist = distance(texCoords, vec2(.5, .5));
    vec3 pixelColor = Texel(currentTexture, texCoords).xyz * smoothstep(.75, .4, dist);
    return vec4(pixelColor, 1.0);
  }
  ]])
  
  dustEmitter = love.graphics.newParticleSystem(love.graphics.newImage('resources/player/emitter_pixel.png'), 64)
  dustEmitter:setParticleLifetime(2, 5)
  dustEmitter:setEmissionRate(15)
  dustEmitter:setSizeVariation(1)
  dustEmitter:setLinearAcceleration(-50, -50, 50, 50)
  dustEmitter:setColors(255, 255, 255, 255, 255, 255, 255, 0)
  
  self.src = love.graphics.newImage('resources/player/p1_spritesheet.png')
  -- self.quad = love.graphics.newQuad(15, 30, 67, 67, self.src:getDimensions())
  self.standQuad = love.graphics.newQuad(67, 196, self.width, self.height, self.src:getDimensions())
  self.jumpQuad = love.graphics.newQuad(438, 93, self.width, self.height, self.src:getDimensions())
  local grid = anim8.newGrid(72, 97, self.src:getDimensions())
  self.animations = {}
  self.animations = anim8.newAnimation(grid('1-3', 1), 0.3)
  -- table.insert(self.animations, love.graphics.newQuad(15, 30, 81, 76, self.src:getDimensions()))
  -- table.insert(self.animations, love.graphics.newQuad(100, 22, 81, 76, self.src:getDimensions()))
  -- table.insert(self.animations, love.graphics.newQuad(201, 28, 81, 76, self.src:getDimensions()))
  -- table.insert(self.animations, love.graphics.newQuad(300, 30, 81, 76, self.src:getDimensions()))
  
  self.bullets = {}
  world:add(self, self.x, self.y, 64, 97)
end

function Player:filter(other)
  local kind = other.name
  if kind == 'Tile' then
    -- this can be moved to collision resolution
    if other.tileId == TILE_CONSUMABLE_HEART or other.tileId == TILE_CONSUMABLE_BLUE_DIAMOND or other.tileId == TILE_BACKGROUND_GRASS then
      other.isVisible = false
      return 'cross'
    end
  elseif kind == 'Enemy' then
    return 'cross'
  else
  end
  return 'slide'
end

function Player:update(self, dt)
  -- print(#self.bullets, bulletFired)
  dustEmitter:update(dt)
  tick.update(dt)
  self.animations:update(dt)
  -- collision detection
  local goalX = self.x + self.xVelocity
  local goalY = self.y + self.yVelocity
  local actualX, actualY, cols, len = world:move(self, goalX, goalY, self.filter)
  
  -- move this to collision resolution function, player strikes with something, see what we can do about it.
  -- player bottom should be touching ground instead of the whole player.
  if len > 0 then
    for item = 1, len do
      if cols[item].other.layer == 'Background' then
        -- normal to collision to determine if side is touched or top of the plane
        if cols[item].normal.y == -1 then
          self.isGrounded = true
        end
        -- print( ('Normal (%d, %d) '):format(cols[item].normal.x, cols[item].normal.y))
      elseif cols[item].other.layer  == 'Enemies' then
        -- world:update(self, self.startX, self.startY)
      elseif cols[item].other.tileId == TILE_CONSUMABLE_BLUE_DIAMOND then
        gemCollect:play()
      elseif cols[item].other.tileId == TILE_CONSUMABLE_HEART then
        heartCollect:play()
      else
      
      end
    end
  end
  self.x, self.y = actualX, actualY
  
  self.xVelocity = self.xVelocity * (1 - math.min(dt * self.friction, 1))
  self.yVelocity = self.yVelocity * (1 - math.min(dt * self.friction, 1))
  
  
  self.yVelocity = self.yVelocity + self.gravity * dt
  
  if love.keyboard.isDown('right', 'd') and self.xVelocity < self.maxSpeed then
    self.xVelocity = self.xVelocity + self.acceleration * dt
  end
  if love.keyboard.isDown('left', 'a') and self.xVelocity > -self.maxSpeed then
    self.xVelocity = self.xVelocity - self.acceleration * dt
  end
  if love.keyboard.isDown('up', 'w') then
    -- not player.hasReachedMax
    if -self.yVelocity < self.jumpMaxSpeed and self.isGrounded then
      jumpSound:play()
      self.yVelocity = self.yVelocity - self.jumpAcceleration * dt
      self.isGrounded = false
    end
--    elseif math.abs(self.yVelocity) > self.jumpMaxSpeed then
--      self.hasReachedMax = true
--    else 
--      self.hasReachedMax = false
--    end
  end
  
  if love.mouse.isDown('1') and not bulletFired then
    bulletFired = true
    -- only allow bullet to be fired after a 0.3 second delay
    local bullet = Bullet(self.x + self.width, self.y + self.height / 2, self.isFacingLeft)
    tick.delay(function() bulletFired = false end, 0.2)
    table.insert(self.bullets, bullet)
  end
  -- if bullet strikes something animate
  for _, bullet in ipairs(self.bullets) do
    if (bullet.x > bullet.startX + love.graphics.getWidth() or bullet.y > bullet.startY + love.graphics.getHeight() or bullet.x < -love.graphics.getWidth() or bullet.y < - love.graphics.getHeight()) then
      -- set a flag to animate bullet
      -- on the next iteration remove bullet
      bullet:destroy(bullet)
      table.remove(self.bullets, _)
    else 
      bullet:update(bullet, dt)
    end
  end
  
  if self.xVelocity < 0 then
    self.isFacingLeft = -1
  else 
    self.isFacingLeft = 1
  end
  strength = dt  * 2
  time = dt
end


function Player:draw(self)
  love.graphics.setShader(playerShader)
  -- playerShader:send("abberationVector", {strength*math.sin(time*7)/200, strength*math.cos(time*7)/200})
  -- love.graphics.draw(self.src, self.animations[1], self.x, self.y, 0, self.isFacingLeft, 1)
  love.graphics.draw(dustEmitter, self.x + self.width /2 , self.y + self.height)
  local originOffsetX = 0
  if self.isFacingLeft == -1 then
    originOffsetX = self.width
  end
  if not self.isGrounded then
    love.graphics.draw(self.src, self.jumpQuad, self.x, self.y, 0, self.isFacingLeft, 1, originOffsetX, 0)
  else
    -- hide running animation if velocity too low
    if math.floor(self.xVelocity) ~= 0 then
      self.animations:draw(self.src, self.x, self.y, 0, self.isFacingLeft, 1, originOffsetX, 0)
    else
      love.graphics.draw(self.src, self.standQuad, self.x, self.y, 0, self.isFacingLeft, 1, originOffsetX, 0)
    end
  end
  
  love.graphics.setShader()

  -- rotate around originOffsetX, default rotation is around top-left, it moves the player outside the bounding box
  -- change rotation offset to top right and then do a scale, changing originOffsetX to always 0 will show you what I mean
  love.graphics.rectangle('line', self.x, self.y, 67, 92, 0, self.isFacingLeft, 1, originOffsetX, 0)
  for _, bullet in ipairs(self.bullets) do
    bullet:draw(bullet)
  end
end
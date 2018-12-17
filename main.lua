require 'helpers/sound_love'
bump = require 'helpers/bump'
anim8 = require 'helpers/anim8'
tick = require 'helpers/tick'

world = bump.newWorld()
require 'levels'
require 'player'
require 'cursor'
require 'enemy'
local gamestate = 'menu'
Camera = require 'helpers/camera'
camera = {}
local cursor
local player

local backgroundMenuMusic
local backgroundGameMusic

-- Implementing my own love.run()
--[[function love.run()
end ]]--

function love.load()
  camera = Camera()

  level1 = Levels()
  player = Player(0, 800)
  cursor = Cursor()
  camera:setFollowStyle('PLATFORMER')
  backgroundMenuMusic = love.audio.play('resources/sfx/menu_music.mp3', 'stream', true)
  backgroundMenuMusic:setVolume(0.1)
  backgroundGameMusic = love.audio.play('resources/sfx/game_music.mp3', 'stream', true)
  backgroundGameMusic:setVolume(0.1)

  love.audio.stop(backgroundGameMusic)
end

function love.update(dt)
  camera:update(dt)
  camera:follow(player.x, player.y)
  cursor:update(cursor, dt)
  if gamestate == 'menu' then
    
  elseif gamestate == 'game' then
    level1:update(level1, dt)
    player:update(player, dt)
  elseif gamestate == 'gamepaused' then
  
  elseif gamestate == 'gamefinished' then
    
  end

end

function love.draw()
  camera:attach()
  cursor:draw(cursor)
  if gamestate == 'menu' then
    love.audio.play(backgroundMenuMusic)
    love.graphics.print("Press Enter to continue .. ", camera:toWorldCoords(300, 300))
  elseif gamestate == 'game' then
    love.audio.stop(backgroundMenuMusic)
    love.audio.play(backgroundGameMusic)
    level1:draw(level1)
    player:draw(player)
  elseif gamestate == 'gamepaused' then
    love.audio.stop(backgroundGameMusic)
    love.audio.play(backgroundMenuMusic)
    love.graphics.print("Paused, Enter to conitnue ..", camera:toWorldCoords(300, 300))
    level1:draw(level1)
    player:draw(player)
  elseif gamestate == 'gamefinished' then
  
  end
  camera:detach()
end

function love.keyreleased(key, scancode)
  if gamestate == 'menu' then
    if key == 'return' then
      gamestate = 'game'
    elseif key == 'escape' then
      love.event.quit()
    end
  elseif gamestate == 'game' then
    if key == 'escape' then
      gamestate = 'gamepaused'
    end
  elseif gamestate == 'gamepaused' then
    if key == 'escape' then
      love.event.quit()
    elseif key == 'return' then
      gamestate = 'game'
    end
  elseif gamestate == 'gamefinished' then
  
  end
end
Object = require 'helpers/classic'
tick = require 'helpers/tick'

require 'tile'
require 'enemy'

Levels = Object:extend()

local widthInTiles = 100

-- tile dimensions for each sheet
local TILE_DIMENSIONS_FOR_SHEET = {
    { width = 64, height = 64 },
    { width = 72, height = 97 }
}

TILE_CONSUMABLE_HEART = 67 + 1
TILE_CONSUMABLE_BLUE_DIAMOND = 49 + 1
TILE_BACKGROUND_GRASS = 72 + 1
TILE_BLANK = 84 + 1

local level1 = require 'resources/levels/level1'
require 'helpers/table2'

function Levels:new()
  self.tilesheet = {}
  self.enemysheet = {}
  self.tilesheetsrc = {
    love.graphics.newImage('resources/levels/tilesheet.png'),
    love.graphics.newImage('resources/enemies/p2_spritesheet.png')
  }
  self.tiles = {}
  self.enemies = {}
  for tilesetIndex = 1, #level1.tilesets do
    local j = 0
    for i=0, level1.tilesets[tilesetIndex].tilecount, 1 do
      if i ~= 0 and i % level1.tilesets[tilesetIndex].columns == 0 then
        j = j + 1
      end
      -- print(('Offset : (%d, %d)'):format(i % level1.tilesets[1].columns * 64, j * 64))
      local quadForTile = love.graphics.newQuad(i % level1.tilesets[tilesetIndex].columns * TILE_DIMENSIONS_FOR_SHEET[tilesetIndex].width, j * TILE_DIMENSIONS_FOR_SHEET[tilesetIndex].height, TILE_DIMENSIONS_FOR_SHEET[tilesetIndex].width, TILE_DIMENSIONS_FOR_SHEET[tilesetIndex].height, self.tilesheetsrc[tilesetIndex]:getDimensions())
      if tilesetIndex == 2 then
        local x, y, w, h = quadForTile:getViewport()
      end
      table.insert(self.tilesheet, quadForTile)
    end
  end
  
  for i = 1, #level1.layers do
    local currentY = 0
    for j = 1, #level1.layers[i].data do
      if j % widthInTiles == 0 then
        currentY = currentY + 1
      end
      if level1.layers[i].data[j] == 0 or level1.layers[i].data[j] == TILE_BLANK then
        -- don't draw tile if no tile present
      elseif level1.layers[i].data[j] == 99 then
        -- if enemy tile, spawn an enemy.
        local enemy = Enemy((j % widthInTiles) * TILE_DIMENSIONS_FOR_SHEET[1].width, currentY * TILE_DIMENSIONS_FOR_SHEET[1].height, TILE_DIMENSIONS_FOR_SHEET[2].width, TILE_DIMENSIONS_FOR_SHEET[2].height, self.tilesheet[level1.layers[i].data[j]], level1.layers[i].data[j], level1.layers[i].name)
        table.insert(self.enemies, enemy)
      else 
        local tile = Tile((j % widthInTiles) * TILE_DIMENSIONS_FOR_SHEET[1].width, currentY * TILE_DIMENSIONS_FOR_SHEET[1].height, TILE_DIMENSIONS_FOR_SHEET[1].width, TILE_DIMENSIONS_FOR_SHEET[1].height, self.tilesheet[level1.layers[i].data[j]], level1.layers[i].data[j], level1.layers[i].name)
        table.insert(self.tiles, tile)
      end
    end
  end
  print(#self.tilesheet .. ' tiles loaded')
  print(#self.tiles .. ' tilemap length')
  print(#self.enemies .. ' enemies loaded')
end

function Levels:update(self, dt)
  for _,enemy in ipairs(self.enemies) do
    if enemy.isVisible == false then
      print('destroying ' .. _)
      world:remove(enemy)
      table.remove(self.enemies, _)
    end
  end
  -- update enemies and tiles
  for _, tile in ipairs(self.tiles) do
    if tile.isVisible == false then
      tile:destroy(tile)
      table.remove(self.tiles, _)
    else 
      tile:update(tile, dt)
    end
  end
  for i = 1, #self.enemies do
    self.enemies[i]:update(self.enemies[i], dt)
  end
end

function Levels:draw(self)
  -- draw enemies and tiles.
  for i = 1, #self.tiles do
    self.tiles[i]:draw(self.tiles[i], self.tilesheetsrc[1])
  end
  for i = 1, #self.enemies do
    self.enemies[i]:draw(self.enemies[i], self.tilesheetsrc[2])
  end
end
--luacheck: globals love

local Draw = {}

local currentFrame = 1
local animationFPS = 1
local tileFloorWidth
local tileFloorHeight

local function worldToScreenCoords(x, y, z, offX, offY)
  local xScreen = (x - y)*(tileFloorWidth/2) + offX
  local yScreen = (x + y)*(tileFloorHeight/2) + z + offY

  return xScreen, yScreen
end

function Draw.tileLayers(tileData)
  tileFloorWidth, tileFloorHeight = tileData.tileFloorWidth, tileData.tileFloorHeight
  for i = 1, #tileData.tileLayers do
    local currentLayer = tileData.tileLayers[i]
    for j = 1, currentLayer.height*currentLayer.width do
      local tileID = currentLayer.data[j]
      if (tileID ~= 0) then
        local x = (j - 1)%currentLayer.width
        local y = math.floor((j - 1)/currentLayer.height)
        local z = currentLayer.offsety

        love.graphics.draw(tileData.tileSheet, tileData.tileQuads[tileID],
                           worldToScreenCoords(x, y, z, 0, 0))
      end
    end
  end
end

function Draw.sprite(sprite, spriteQuads, spriteSheets, layerOffset)
  local spriteSheet = spriteSheets[sprite.name]
  local x = sprite.x/sprite.width
  local y = sprite.y/sprite.height
  local offX = sprite.properties.offsetx
  local offY = sprite.properties.offsety
  animationFPS = sprite.properties.fps
  local spriteQuad = spriteQuads[sprite.id][currentFrame]
  if (not spriteQuad) then
    currentFrame = 1
    spriteQuad = spriteQuads[sprite.id][currentFrame]
  end
  local xScale = 1
  local flipOffset = 0
  local quadWidth = select(3, spriteQuad:getViewport())
  if (sprite.properties.flip) then
    xScale = -1
    flipOffset = quadWidth
  end
  local xScreen,yScreen = worldToScreenCoords(x, y, layerOffset, offX, offY)
  love.graphics.draw(spriteSheet, spriteQuad, xScreen, yScreen, 0, xScale, 1, flipOffset)
end

function Draw.objectLayers(objectLayers, spriteQuads, spriteSheets)
  for i = 1, #objectLayers do
    local currentLayer = objectLayers[i]

    local objects = currentLayer.objects
    for j = 1, #objects do
      if (objects[j].type == "sprite") then
        Draw.sprite(objects[j], spriteQuads, spriteSheets, currentLayer.offsety)
      end
    end
  end
end

local dtotal = 0
function love.update(dt)
  dtotal = dtotal + dt

  if (dtotal >= 1/animationFPS) then
    currentFrame = currentFrame + 1
    dtotal = dtotal - 1/animationFPS
  end
end

return Draw

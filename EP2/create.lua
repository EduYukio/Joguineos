--luacheck: globals love

local Create = {}

local Extract = require "extract"
local Calculate = require "calculate"

Create.spriteSheets = {}

local function loadSpriteSheet(sprite)
  if (not Create.spriteSheets[sprite.name]) then
    Create.spriteSheets[sprite.name] =
      love.graphics.newImage("chars/".. sprite.name ..".png")
  end
end

function Create.frameQuads(sprite, spriteSheet, quads)
  local frameTable = Extract.frames(sprite)
  for frame = 1, #frameTable do
    local spriteWidth, spriteHeight =
      Calculate.quadDimensions(sprite, spriteSheet)

    local x0, y0 =
      Calculate.quadCoords(frameTable[frame], spriteWidth, spriteHeight,
                           sprite.properties.columns)

    local newQuad =
      love.graphics.newQuad(x0, y0, spriteWidth, spriteHeight,
                            spriteSheet:getDimensions())

    table.insert(quads[sprite.id], newQuad)
  end
end

function Create.tileQuads(tileData)
  local quads = {}
  for i = 1, #tileData.tileLayers do
    local currentLayer = tileData.tileLayers[i]
    for j = 1, currentLayer.height*currentLayer.width do
      local tileID = currentLayer.data[j]
      if (not quads[tileID]) then
        local x0, y0 = Calculate.tileQuadCoords(tileID, tileData)

        quads[tileID] =
          love.graphics.newQuad(x0, y0, tileData.tileWidth,
            tileData.tileHeight, tileData.tileSheet:getDimensions())
      end
    end
  end
  return quads
end

function Create.spriteQuads(objectLayers)
  local quads = {}
  for i = 1, #objectLayers do
    local currentLayer = objectLayers[i]
    local sprites = Extract.sprites(currentLayer)

    for j = 1, #sprites do
      local sprite = sprites[j]
      loadSpriteSheet(sprite)
      local spriteSheet = Create.spriteSheets[sprite.name]
      quads[sprite.id] = {}

      Create.frameQuads(sprite, spriteSheet, quads)
    end
  end
  return quads
end

return Create
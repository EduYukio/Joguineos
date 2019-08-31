--luacheck: globals love

local map
local tileLayers
local objectLayers

local tileQuads
local spriteQuads
local spriteSheets

local tileSheet
local tileHeight
local tileWidth
local tileColumns

local tileFloorWidth
local tileFloorHeight

local function worldToScreenCoords(x, y, z, offX, offY)
  local xScreen = (x - y) * (tileFloorWidth / 2) + offX
  local yScreen = (x + y) * (tileFloorHeight / 2) + z + offY

  return xScreen, yScreen
end

local function calculateQuadStartCoord(id, width, height, columns)
    local x0 = width * ((id - 1) % columns)
    local y0 = height * math.floor((id - 1) / columns)

    return x0, y0
end

local function calculateQuadDimensions(sprite, spriteSheet)
    local sheetWidth, sheetHeight = spriteSheet:getDimensions()

    local quadWidth = sheetWidth/sprite.properties.columns
    local quadHeight = sheetHeight/sprite.properties.rows

    return quadWidth, quadHeight
end

local function drawTileLayers()
  for i = 1, #tileLayers do
    local currentLayer = tileLayers[i]

    for j = 1, currentLayer.height * currentLayer.width do
      local tileID = currentLayer.data[j]
      if(tileID ~= 0) then
        local x = (j - 1) % currentLayer.width
        local y = math.floor((j - 1) / currentLayer.height)
        local z = currentLayer.offsety

        love.graphics.draw(tileSheet, tileQuads[tileID], worldToScreenCoords(x,y,z,0,0))
      end
    end
  end
end

local function extractMapLayers(type)
  local t = {}

  for _, layer in ipairs(map.layers) do
    if(layer.type == type) then
      table.insert(t, layer)
    end
  end

  return t
end

local function extractSprites(objectLayer)
  local t = {}

  for _, layer in ipairs(objectLayer.objects) do
    if(layer.type == "sprite") then
      table.insert(t, layer)
    end
  end

  return t
end

local function extractFrames(sprite)
  local t = {}

  for frame_token in sprite.properties.frames:gmatch("%d+") do
    local frame = tonumber(frame_token)

    table.insert(t, frame)
  end

  return t
end

local function extractTileInfos()
  tileSheet = love.graphics.newImage("maps/tilesheet_complete.png")
  local tileSet = map.tilesets[1]

  tileHeight = tileSet.tileheight
  tileWidth = tileSet.tilewidth
  tileColumns = tileSet.columns

  tileFloorWidth = map.tilewidth
  tileFloorHeight = map.tileheight
end

local function createTileQuads()
  local quads = {}
  for i = 1, #tileLayers do
    local currentLayer = tileLayers[i]

    for j = 1, currentLayer.height * currentLayer.width do
      local tileID = currentLayer.data[j]
      if(not quads[tileID]) then
        local x0, y0 = calculateQuadStartCoord(tileID, tileWidth, tileHeight, tileColumns)
        quads[tileID] = love.graphics.newQuad(x0, y0, tileWidth, tileHeight, tileSheet:getDimensions())
      end
    end
  end
  return quads
end

local function createSpriteQuads()
  local quads = {}

  for i = 1, #objectLayers do
    local currentLayer = objectLayers[i]
    local sprites = extractSprites(currentLayer)
    for j = 1, #sprites do
      local sprite = sprites[j]
      if(not spriteSheets[sprite.name]) then
        spriteSheets[sprite.name] = love.graphics.newImage("chars/".. sprite.name ..".png")
      end
      local spriteSheet = spriteSheets[sprite.name]

      local frameTable = extractFrames(sprite)
      quads[sprite.id] = {}
      for k = 1, #frameTable do
        local spriteWidth, spriteHeight = calculateQuadDimensions(sprite, spriteSheet)
        local x0, y0 = calculateQuadStartCoord(frameTable[k], spriteWidth, spriteHeight, sprite.properties.columns)

        local newQuad = love.graphics.newQuad(x0, y0, spriteWidth, spriteHeight, spriteSheet:getDimensions())

        table.insert(quads[sprite.id], newQuad)
      end
    end
  end

  return quads
end

local function drawSprite(sprite, layerOffset)
  local spriteSheet = spriteSheets[sprite.name]

  local x = sprite.x/sprite.width
  local y = sprite.y/sprite.height
  local offX = sprite.properties.offsetx
  local offY = sprite.properties.offsety

  love.graphics.draw(spriteSheet, spriteQuads[sprite.id][4], worldToScreenCoords(x,y,layerOffset, offX, offY))
end

local function drawObjectLayers()
  for i = 1, #objectLayers do
    local currentLayer = objectLayers[i]

    local objects = currentLayer.objects
    for j = 1, #objects do
      if(objects[j].type == "sprite") then
        drawSprite(objects[j], currentLayer.offsety)
      end
    end
  end
end

function love.load(args)
  map = love.filesystem.load("maps/".. args[1] ..".lua")()

  extractTileInfos()

  tileLayers = extractMapLayers("tilelayer")
  objectLayers = extractMapLayers("objectgroup")

  tileQuads = createTileQuads()
  tileQuads[0] = true


  spriteSheets = {}
  spriteQuads = createSpriteQuads()
end

function love.draw()
  love.graphics.translate(550,120)
  love.graphics.scale(0.75,0.75)
  love.graphics.setBackgroundColor( 1/255, 253/255, 254/255, 1)

  drawTileLayers()
  drawObjectLayers()
end


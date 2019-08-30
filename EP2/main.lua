--luacheck: globals love

local map
local tileLayers
local objectLayers

local tileQuads
local tileSheet
local tileHeight
local tileWidth
local tileColumns

local function worldToScreenCoords(x, y, z)
  local xScreen = (x - y) * (tileWidth / 2)
  local yScreen = (x + y) * (tileHeight / 4) + z

  return xScreen, yScreen
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

        love.graphics.draw(tileSheet, tileQuads[tileID], worldToScreenCoords(x,y,z))
      end
    end
  end
end

local function extractMapLayers(type)
  local t = {}
  for _, layer in ipairs(map.tileLayers) do
    if(layer.type == type) then
      table.insert(t, layer)
    end
  end

  return t
end

local function extractTileInfos()
  tileSheet = love.graphics.newImage("maps/tilesheet_complete.png")
  local tileSet = map.tilesets[1]

  tileHeight = tileSet.tileheight
  tileWidth = tileSet.tilewidth
  tileColumns = tileSet.columns
end

local function createTileQuads()
  local quads = {}
  for i = 1, #tileLayers do
    local currentLayer = tileLayers[i]

    for j = 1, currentLayer.height * currentLayer.width do
      local tileID = currentLayer.data[j]
      if(not quads[tileID]) then
        quads[tileID] = love.graphics.newQuad(
          tileWidth * ((tileID - 1) % tileColumns),
          tileHeight * math.floor((tileID - 1) / tileColumns),
          tileWidth, tileHeight, tileSheet:getDimensions())
      end
    end
  end
  return quads
end

function love.load(args)
  map = love.filesystem.load("maps/".. args[1] ..".lua")()

  extractTileInfos()

  tileLayers = extractMapLayers("tilelayer")
  objectLayers = extractMapLayers("objectgroup")
  tileQuads = createTileQuads()
  tileQuads[0] = true
end

function love.draw()
  love.graphics.translate(550,120)
  love.graphics.scale(0.5,0.5)

  drawTileLayers()
end


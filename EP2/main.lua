--luacheck: globals love

local map
local tileSheet

local quads
local currentLayer
local layerHeight
local layerWidth
local tileSet
local tileHeight
local tileWidth
local columns
local layers

function love.load(args)
  local mapName = args[1]
  local mapFile = love.filesystem.load("maps/".. mapName ..".lua")
  map = mapFile()

  tileSheet = love.graphics.newImage("maps/tilesheet_complete.png")

  layers = {}
  for _, layer in ipairs(map.layers) do
    if(layer.type == "tilelayer") then
      table.insert(layers, layer)
    end
  end

  tileSet = map.tilesets[1]
  tileHeight = tileSet.tileheight
  tileWidth = tileSet.tilewidth
  columns = tileSet.columns

  quads = {}
  quads[0] = true
  for i = 1, #layers do
    currentLayer = layers[i]
    layerHeight = currentLayer.height
    layerWidth = currentLayer.width

    for j = 1, layerHeight * layerWidth do
      local tileID = currentLayer.data[j]

      if(not quads[tileID]) then
        local x0 = tileWidth * ((tileID - 1) % columns)
        local y0 = tileHeight * math.floor((tileID - 1) / columns)

        quads[tileID] = love.graphics.newQuad(x0, y0, tileWidth, tileHeight, tileSheet:getDimensions())
      end
    end
  end
end

function love.draw()
  love.graphics.translate(550,120)
  love.graphics.scale(0.5,0.5)

  for i = 1, #layers do
    currentLayer = layers[i]
    for j = 1, layerHeight * layerWidth do
      local tileID = currentLayer.data[j]
      if(tileID ~= 0) then
        local x = (j - 1) % layerWidth
        local y = math.floor((j - 1) / layerHeight)
        local z = currentLayer.offsety

        local xMonitor = (x - y) * (tileWidth / 2)
        local yMonitor = (x + y) * (tileHeight / 4) + z
        love.graphics.draw(tileSheet, quads[tileID], xMonitor, yMonitor)
      end
    end
  end
end

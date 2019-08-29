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

function love.load(args)
  local mapName = args[1]
  local mapFile = love.filesystem.load("maps/" .. mapName .. ".lua")
  map = mapFile()

  tileSheet = love.graphics.newImage("maps/tilesheet_complete.png")

  currentLayer = map.layers[2] --L00
  layerHeight = currentLayer.height
  layerWidth = currentLayer.width
  quads = {}
  quads[0] = true
  tileSet = map.tilesets[1]

  tileHeight = tileSet.tileheight
  tileWidth = tileSet.tilewidth
  columns = tileSet.columns

  for i = 1, layerHeight*layerWidth do
    local tileID = currentLayer.data[i]
    -- local lines = map.tilesets[0].tilecount/columns

    if(not quads[tileID]) then
      -- print("criou quad")
      local x0 = tileWidth * (tileID - 1)%columns
      local y0 = tileHeight * math.floor((tileID-1)/columns)
      local x1 = x0 + tileWidth
      local y1 = y0 + tileHeight

      quads[tileID] = love.graphics.newQuad(x0,y0, x1, y1, tileSheet:getDimensions())
    end
  end
end


function love.draw()
	love.graphics.print(map.luaversion, 200, 200)
end
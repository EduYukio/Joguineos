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
  -- for i = 10, 10 do
    local tileID = currentLayer.data[i]

    if(not quads[tileID]) then
      -- print("criou o quad "..tileID)

      local x0 = tileWidth * ((tileID - 1)%columns)
      local y0 = tileHeight * math.floor((tileID-1)/columns)

      quads[tileID] = love.graphics.newQuad(x0,y0, tileWidth, tileHeight, tileSheet:getDimensions())
    end
  end
end


function love.draw()
  -- print(map.tilesets[1])
  -- currentLayer = map.layers[1] --L00

  -- love.graphics.draw(tileSheet, quads[2], 200, 200)
  love.graphics.translate(550,50)
  love.graphics.scale(0.5,0.5)

  for j = 1, layerHeight*layerWidth do
    local tileID = currentLayer.data[j]
    if(tileID ~= 0) then
      -- print(tileID)
      local x = (j-1)%layerWidth
      local y = math.floor((j-1)/layerHeight
        )
      -- print("j: "..j)
      -- print("x: "..x)
      -- print("y: "..y)
      -- print("")

      local z = currentLayer.offsety

      local xMonitor = (x-y)*(tileWidth/2)
      local yMonitor = (x+y)*(tileHeight/4) + z
      love.graphics.draw(tileSheet, quads[tileID], xMonitor, yMonitor)
    end
  end
end

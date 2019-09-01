--luacheck: globals love

local Extract = require "extract"
local Create = require "create"
local Draw = require "draw"

local map

local tileLayers
local objectLayers

local tileQuads
local spriteQuads

local tileData

local function extractTileData()
  local data = {}

  local tileSet = map.tilesets[1]
  data.tileSet = tileSet
  data.tileSheet = love.graphics.newImage("maps/" .. tileSet.image)

  data.tileHeight = tileSet.tileheight
  data.tileWidth = tileSet.tilewidth
  data.tileColumns = tileSet.columns

  data.tileFloorWidth = map.tilewidth
  data.tileFloorHeight = map.tileheight

  return data
end

function love.load(args)
  map = love.filesystem.load("maps/".. args[1] ..".lua")()
  tileData = extractTileData()

  objectLayers = Extract.mapLayers(map, "objectgroup")
  tileLayers = Extract.mapLayers(map, "tilelayer")
  tileData.tileLayers = tileLayers

  spriteQuads = Create.spriteQuads(objectLayers)
  tileQuads = Create.tileQuads(tileData)
  tileData.tileQuads = tileQuads
end

function love.draw()
  love.graphics.setBackgroundColor(1/255, 253/255, 254/255, 1)
  love.graphics.translate(550,20)

  Draw.tileLayers(tileData)
  Draw.objectLayers(objectLayers, spriteQuads, Create.spriteSheets)
end

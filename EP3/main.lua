--luacheck: globals love

local Entity = require "entity/entity"
local Update = require "common/update"
local Draw = require "common/draw"
local Get = require "common/get"

local entities = {}
local direction
local scene

function love.load(args)
  math.randomseed(os.time())

  scene = love.filesystem.load("scene/" .. args[1] .. ".lua")()

  for i = 1, #scene do
    for _ = 1, scene[i].n do
      local name = scene[i].entity
      local initialState = require("entity/" .. name)
      local entity = Entity(name, initialState)
      table.insert(entities, entity)
    end
  end
end

function love.update(dt)
  for _, entity in ipairs(entities) do
    direction = Update.inputHandler(entity)

    local currentMotion = Get.currentMotion(entity)
    local newMotion = Update.control(entity, dt, currentMotion, direction)

    local currentPosition = Get.currentPosition(entity)
    local newPosition = Update.movement(entity, dt, newMotion, currentPosition)

    Update.position(entity, newPosition)
    Update.body(entity, entities)
  end
end

function love.draw()
  local screenWidth, screenHeight = love.graphics.getDimensions()
  love.graphics.translate(screenWidth/2, screenHeight/2)
  for _, entity in ipairs(entities) do
    if entity.position then
      local x, y = entity.position.point:get()
      if entity.name == "player" then
        love.graphics.translate(-x, -y)
        Draw.player(x, y, direction)
      else
        Draw.nonPlayerEntities(entity, x, y)
      end
    end
  end
  love.graphics.setColor(1, 1, 1)
  love.graphics.circle("line", 0, 0, 1000)
end


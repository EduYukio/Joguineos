--luacheck: globals love

local InputHandler = require "component/inputHandler"
local Entity = require "entity/entity"

local Update = require "common/update"
local Get = require "common/get"
local Draw = require "common/draw"

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
    direction = InputHandler.update()

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
    local x, y = entity.position.point:get()
    if entity.name == "player" then
      love.graphics.translate(-x, -y)
      Draw.player(x, y, direction)
    else
      Draw.nonPlayerEntities(entity, x, y)
    end
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.circle("line", 0, 0, 1000)
end


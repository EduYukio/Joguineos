--luacheck: globals love

local InputHandler = require "component/inputHandler"
local Entity = require "entity/entity"
local Calculate = require "common/calculate"

local pointingAngle = 0
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
    local updatedMotion
    local updatedPosition
    local currentMotion
    local currentPosition

    if entity.movement then
      currentMotion = entity.movement.motion
    end

    direction = InputHandler.update()
    if entity.control then
      updatedMotion = entity.control:update(dt, currentMotion, direction)
    end

    if entity.position then
      currentPosition = entity.position.point
    end

    if entity.movement then
      updatedPosition = entity.movement:update(dt, updatedMotion, currentPosition)
    end

    if entity.position then
      entity.position:update(updatedPosition)
    end

    if entity.body then
      entity.body:update(entity, entities)
    end
  end
end

local function rotatePlayerToFaceDirection(x, y)
  pointingAngle = Calculate.pointingAngle(direction, pointingAngle)
  local triangleVertexes = {x - 3, y - 4, x + 3, y - 4, x + 0, y + 6}
  love.graphics.push()

  love.graphics.translate(x - 1.5, y - 2)
  love.graphics.rotate(pointingAngle)
  love.graphics.translate(-x + 1.5, -y + 2)

  love.graphics.setColor(1, 1, 1)
  love.graphics.polygon('fill', triangleVertexes)

  love.graphics.pop()
end

function love.draw()
  local screenWidth, screenHeight = love.graphics.getDimensions()
  love.graphics.translate(screenWidth/2, screenHeight/2)

  for _, entity in ipairs(entities) do
    local x, y = entity.position.point:get()
    if entity.name == "player" then
      love.graphics.translate(-x, -y)
      rotatePlayerToFaceDirection(x, y)
    else
      love.graphics.setColor(0, 1, 0)
      if entity.body then
        love.graphics.circle("fill", x, y, entity.body.size)
      else
        love.graphics.circle("line", x, y, 8)
      end
    end
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.circle("line", 0, 0, 1000)
end


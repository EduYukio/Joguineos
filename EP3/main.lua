--luacheck: globals love

local Entity = require "entity/entity"

local scene
local direction
local pointingAngle = 0
local entities = {}

local InputHandler = require "component/inputHandler"
local function calculatePointingAngle(previousAngle)
  local x, y = direction:get()
  local angle = 0
  local step = math.pi/4

  if x == -1 then
    if y == 1 then
      angle = step
    elseif y == 0 then
      angle = 2*step
    elseif y == -1 then
      angle = 3*step
    end
  elseif x == 0 then
    if y == 1 then
      angle = 0
    elseif y == 0 then
      angle = previousAngle
    elseif y == -1 then
      angle = 4*step
    end
  elseif x == 1 then
    if y == 1 then
      angle = -1*step
    elseif y == 0 then
      angle = -2*step
    elseif y == -1 then
      angle = -3*step
    end
  end

  return angle
end


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

    if entity.field    then entity.field:update()    end
    if entity.charge   then entity.charge:update()   end
  end
end

function love.draw()
  love.graphics.translate(1280/2, 600/2)

  -- love.graphics.scale(0.3,0.3)

  for _, entity in ipairs(entities) do
    local x, y = entity.position.point:get()
    if(entity.name == "player") then
      love.graphics.translate(-x, -y)
      love.graphics.setColor(1, 1, 1)

      love.graphics.push()
      love.graphics.translate(x - 1.5, y - 2)
      pointingAngle = calculatePointingAngle(pointingAngle)
      love.graphics.rotate(pointingAngle)
      love.graphics.translate(-x + 1.5, -y + 2)
      love.graphics.polygon('fill', x - 3, y - 4, x + 3, y - 4, x + 0, y + 6)
      love.graphics.pop()
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


--luacheck: globals love class

local scene
local inputHandler
local direction
local pointingAngle = 0
local entities = {}

class = require "class"
local Vec = require 'common/vec'

require "component/inputHandler"
require "component/position"
require "component/movement"
require "component/body"
require "component/control"
require "component/field"
require "component/charge"

class.Entity()

function Entity:_init(name, initialState) -- luacheck: ignore
  self.name = name
  self.initialState = initialState

  local position = initialState.position
  if not position then
    self.position = nil
  elseif name == "player" then
    self.position = Position(Vec(0,0)) -- luacheck: ignore
  else
    self.position = Position(position.point) -- luacheck: ignore
  end

  local movement = initialState.movement
  if not movement then
    self.movement = nil
  else
    self.movement = Movement(movement.motion) -- luacheck: ignore
  end

  self.body = nil

  local control = initialState.control
  if not control then
    self.control = nil
  else
    self.control = Control(control.acceleration, control.max_speed) -- luacheck: ignore
  end

  self.field = nil
  self.charge = nil
end



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
  inputHandler = InputHandler() -- luacheck: ignore

  for i = 1, #scene do
    for _ = 1, scene[i].n do
      local name = scene[i].entity
      local initialState = require("entity/" .. name)
      local entity = Entity(name, initialState) -- luacheck: ignore
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

    if entity.body     then entity.body:update()     end

    if entity.movement then
      currentMotion = entity.movement.motion
    end

    direction = inputHandler:update()
    if entity.control then
      updatedMotion = entity.control:update(dt, currentMotion, direction)
    end

    if entity.position then
      currentPosition = entity.position.point
    end

    if entity.movement then
      updatedPosition = entity.movement:update(dt, updatedMotion, currentPosition)
    end

    if entity.position then entity.position:update(updatedPosition) end

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
      love.graphics.circle("line", x, y, 8)
    end
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.circle("line", 0, 0, 1000)
end


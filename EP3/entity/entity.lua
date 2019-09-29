local Vec = require 'common/vec'
local Entity = require "class"()

local Position = require "component/position"
local Movement = require "component/movement"
local Control = require "component/control"
local Body = require "component/body"

local function setPosition(initPosition, name)
  local position

  if not initPosition then
    position = nil
  elseif name == "player" then
    position = Position(Vec(0,0))
  else
    position = Position(initPosition.point)
  end

  return position
end

local function setMovement(initMovement)
  local movement

  if not initMovement then
    movement = Movement()
  else
    movement = Movement(initMovement.motion)
  end

  return movement
end

local function setControl(initControl)
  local control

  if not initControl then
    control = nil
  else
    control = Control(initControl.acceleration, initControl.max_speed)
  end

  return control
end

local function setBody(initBody)
  local body

  if not initBody then
    body = nil
  else
    body = Body(initBody.size)
  end

  return body
end

function Entity:_init(name, initialState)
  self.name = name
  self.initialState = initialState

  self.position = setPosition(initialState.position, name)
  self.movement = setMovement(initialState.movement)
  self.control = setControl(initialState.control)
  self.body = setBody(initialState.body)
end

return Entity
local Entity = require "class"()

local Position = require "component/position"
local Movement = require "component/movement"
local Body = require "component/body"
local Control = require "component/control"

local Vec = require 'common/vec'

function Entity:_init(name, initialState)
  self.name = name
  self.initialState = initialState

  local position = initialState.position
  if not position then
    self.position = nil
  elseif name == "player" then
    self.position = Position(Vec(0,0))
  else
    self.position = Position(position.point)
  end

  local movement = initialState.movement
  if not movement then
    self.movement = Movement()
  else
    self.movement = Movement(movement.motion)
  end

  local body = initialState.body
  if not body then
    self.body = nil
  else
    self.body = Body(body.size)
  end

  local control = initialState.control
  if not control then
    self.control = nil
  else
    self.control = Control(control.acceleration, control.max_speed)
  end

  self.field = nil
  self.charge = nil
end

return Entity
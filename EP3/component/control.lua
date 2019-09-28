--luacheck: globals love class


class = require "class"
class.Control()

local Vec = require 'common/vec'

function Control:_init(acceleration, max_speed) -- luacheck: ignore
  if not acceleration then
    self.acceleration = 0.0
  else
    self.acceleration = acceleration
  end

  if not max_speed then
    self.max_speed = 50.0
  else
    self.max_speed = max_speed
  end
end

local direction
local function handleInput()
  direction = Vec(0,0)

  if love.keyboard.isDown("up") then
    direction.y = -1
  end

  if love.keyboard.isDown("down") then
    direction.y = 1
  end

  if love.keyboard.isDown("left") then
    direction.x = -1
  end

  if love.keyboard.isDown("right") then
    direction.x = 1
  end

  return direction
end

function Control:update(dt, v0) -- luacheck: ignore
  local i = handleInput()

  local v = i*(self.acceleration*dt) + v0

  v:clamp(self.max_speed)

  return v
end

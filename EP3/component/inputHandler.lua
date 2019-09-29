--luacheck: globals love class

class = require "class"
class.InputHandler()

local Vec = require 'common/vec'

function InputHandler:update() -- luacheck: ignore
	local direction = Vec(0,0)

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
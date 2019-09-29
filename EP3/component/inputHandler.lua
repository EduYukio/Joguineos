--luacheck: globals love

local InputHandler = require "class"()
local Vec = require 'common/vec'

function InputHandler.update()
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

return InputHandler
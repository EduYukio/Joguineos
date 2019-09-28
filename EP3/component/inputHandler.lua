--luacheck: globals love class

class = require "class"
class.InputHandler()

local Vec = require 'common/vec'

function InputHandler:_init() -- luacheck: ignore
	self.direction = Vec(0,0)
end

function InputHandler:update() -- luacheck: ignore
	self.direction = Vec(0,0)

  if love.keyboard.isDown("up") then
    self.direction.y = -1
  end

  if love.keyboard.isDown("down") then
    self.direction.y = 1
  end

  if love.keyboard.isDown("left") then
    self.direction.x = -1
  end

  if love.keyboard.isDown("right") then
    self.direction.x = 1
  end

  return self.direction
end
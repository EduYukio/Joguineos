--luacheck: globals love class

class = require "class"
class.Position()

local Vec = require 'common/vec'

function Position:_init(point) -- luacheck: ignore
  if not point then
    local randomX = math.random(-900, 900)

    local maxY = math.sqrt(900^2 - randomX^2)
    local randomY = math.random(-maxY, maxY)

    self.point = Vec(randomX, randomY)
  else
    self.point = point
  end
end

function Position:update(updatedPosition) -- luacheck: ignore
  if updatedPosition then
    self.point = updatedPosition
  end

  local x, y = self.point:get()
  if x^2 + y^2 >= 1000^2 then
    self.point.x = -x
    self.point.y = -y
  end
end

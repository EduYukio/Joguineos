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

function Position:update(x) -- luacheck: ignore
  if x then
    self.point = x
  end
end

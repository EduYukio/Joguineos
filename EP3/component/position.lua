--luacheck: globals love

local Position = require "class"()
local Vec = require 'common/vec'

function Position:_init(point)
  if not point then
    local maxRadius = 750
    local randomX = math.random(-maxRadius, maxRadius)

    local maxY = math.sqrt(maxRadius^2 - randomX^2)
    local randomY = math.random(-maxY, maxY)

    self.point = Vec(randomX, randomY)
  else
    self.point = point
  end
end

function Position:update(newPosition)
  self.point = newPosition

  local x, y = self.point:get()
  if x^2 + y^2 >= 1000^2 then
    self.point.x = -x
    self.point.y = -y
  end
end

return Position
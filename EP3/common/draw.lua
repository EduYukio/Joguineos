--luacheck: globals love

local Draw = {}

local Calculate = require "common/calculate"
local pointingAngle = 0

local function rotateToFaceDirection(x, y, direction)
  pointingAngle = Calculate.pointingAngle(direction, pointingAngle)
  love.graphics.translate(x - 1.5, y - 2)
  love.graphics.rotate(pointingAngle)
  love.graphics.translate(-x + 1.5, -y + 2)
end

function Draw.player(x, y, direction)
  local triangleVertexes = {x - 3, y - 4, x + 3, y - 4, x + 0, y + 6}

  love.graphics.push()

  rotateToFaceDirection(x, y, direction)
  love.graphics.setColor(1, 1, 1)
  love.graphics.polygon('fill', triangleVertexes)

  love.graphics.pop()
end

function Draw.nonPlayerEntities(entity, x, y)
  love.graphics.setColor(0, 1, 0)

  if entity.body then
    love.graphics.circle("fill", x, y, entity.body.size)
  else
    love.graphics.circle("line", x, y, 8)
  end
end

return Draw
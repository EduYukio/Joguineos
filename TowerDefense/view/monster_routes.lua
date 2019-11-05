
local MonsterRoutes = require 'common.class' ()

function MonsterRoutes:draw() -- luacheck: no self
  local g = love.graphics
  g.push()

  g.setLineWidth(0.5)
  g.setColor(0.7, 0.7, 0.7, 0.3)
  g.line(76,76, 300, 524)
  g.line(300,76, 300, 524)
  g.line(524,76, 300, 524)
  g.setLineWidth(2)

  g.pop()
end

return MonsterRoutes


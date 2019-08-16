-- luacheck: no global

local simulator = require "simulator"

function love.draw()
  love.graphics.print(simulator.calculateTriangleBonus("sword", "lance"), 400, 300)
end
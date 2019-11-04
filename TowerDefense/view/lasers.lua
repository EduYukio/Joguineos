
local Lasers = require 'common.class' ()

function Lasers:_init()
  self.list = {}
end

function Lasers:get_position()
  return self.position:get()
end

function Lasers:add(unit, tower_position, target_position, color)
  self.list[unit] = {
    tower_position = tower_position,
    target_position = target_position,
    color = color,
  }
end

function Lasers:remove(unit)
  self.list[unit] = nil
end

function Lasers:draw()
  local g = love.graphics
  g.push()


  for _, laser in pairs(self.list) do
    local x1, y1 = laser.tower_position:get()
    local x2, y2 = laser.target_position:get()
    g.setColor(laser.color)
    g.line(x1,y1, x2,y2)
  end

  g.pop()
end

return Lasers


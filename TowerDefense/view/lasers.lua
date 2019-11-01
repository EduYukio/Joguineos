
local Lasers = require 'common.class' ()

function Lasers:_init()
  self.list = {}
end

function Lasers:get_position()
  return self.position:get()
end

function Lasers:add(unit, tower_position, monster_position)
  self.list[unit] = {tower_position, monster_position}
end

function Lasers:remove(unit)
  self.list[unit] = nil
end

function Lasers:draw()
  local g = love.graphics
  g.push()

  g.setColor(0.6, 0, 0)

  for _, laser in pairs(self.list) do
    local x1, y1 = laser[1]:get()
    local x2, y2 = laser[2]:get()
    g.line(x1,y1, x2,y2)
  end

  g.pop()
end

return Lasers



local Laser = require 'common.class' ()

function Laser:_init()
  self.list = {}
end

function Laser:get_position()
  return self.position:get()
end

function Laser:add(id, tower_position, monster_position)
  self.list[id] = {tower_position, monster_position}
end

function Laser:remove(id)
  self.list[id] = nil
end

function Laser:draw()
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

return Laser



local Lasers = require 'common.class' ()

function Lasers:_init()
  self.list = {}
end

function Lasers:get_position()
  return self.position:get()
end

function Lasers:add(tower, index, tower_position, target_position, color)
  local laser = {
    tower_position = tower_position,
    target_position = target_position,
    color = color,
  }

  if not self.list[tower] then
    self.list[tower] = {false, false, false}
  end

  self.list[tower][index] = laser
end

function Lasers:remove(tower, index)
  self.list[tower][index] = nil
end

function Lasers:draw()
  local g = love.graphics
  g.push()


  for _, tower in pairs(self.list) do
    for _, laser in pairs(tower) do
      if laser then
        local x1, y1 = laser.tower_position:get()
        local x2, y2 = laser.target_position:get()
        g.setColor(laser.color)
        g.line(x1,y1, x2,y2)
      end
    end
  end

  g.pop()
end

return Lasers


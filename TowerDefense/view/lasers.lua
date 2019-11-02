
local Lasers = require 'common.class' ()
local PALETTE_DB = require 'database.palette'

function Lasers:_init()
  self.list = {}
end

function Lasers:get_position()
  return self.position:get()
end

function Lasers:add(unit, tower_position, monster_position)
  self.list[unit] = {
    tower_position = tower_position,
    monster_position = monster_position
  }
end

function Lasers:remove(unit)
  self.list[unit] = nil
end

function Lasers:draw()
  local g = love.graphics
  g.push()

  g.setColor(PALETTE_DB.red)

  for _, laser in pairs(self.list) do
    local x1, y1 = laser.tower_position:get()
    local x2, y2 = laser.monster_position:get()
    g.line(x1,y1, x2,y2)
  end

  g.pop()
end

return Lasers


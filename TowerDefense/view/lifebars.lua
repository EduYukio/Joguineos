
local Vec = require 'common.vec'
local Lifebars = require 'common.class' ()

function Lifebars:_init()
  self.list = {}
end

function Lifebars:add(unit, pos)
  local lifeBarsPos = pos:clone()
  lifeBarsPos:add(Vec(0, -22))
  self.list[unit] = lifeBarsPos
end

function Lifebars:remove(unit)
  self.list[unit] = nil
end

function Lifebars:add_position(unit, value)
  self.list[unit] = self.list[unit] + value
end

function Lifebars:draw()
  local g = love.graphics
  g.push()

  g.setColor(0, 1, 0)

  for _, lifebar_position in pairs(self.list) do

    local x1, y1 = lifebar_position:get()
    local x_offset = 12
    local y_offset = 2
    x1 = x1 - x_offset
    y1 = y1 - y_offset

    love.graphics.rectangle("fill", x1, y1, 24, 5)
  end

  g.pop()
end

return Lifebars


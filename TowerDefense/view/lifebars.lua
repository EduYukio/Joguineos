
local Vec = require 'common.vec'
local Lifebars = require 'common.class' ()

function Lifebars:_init()
  self.list = {}
end

function Lifebars:add(unit, pos)
  local lifeBarsPos = pos:clone()
  lifeBarsPos:add(Vec(0, -22))
  self.list[unit] = {
    position = lifeBarsPos,
    x_scale = 1
  }
end

function Lifebars:remove(unit)
  self.list[unit] = nil
end

function Lifebars:add_position(unit, value)
  self.list[unit].position = self.list[unit].position + value
end

function Lifebars:x_scale(unit, value)
  if self.list[unit] then
    self.list[unit].x_scale = value
  end
end

function Lifebars:draw()
  local g = love.graphics
  g.push()

  g.setColor(0, 1, 0)

  for _, lifebar in pairs(self.list) do

    local x1, y1 = lifebar.position:get()
    local x_scale = lifebar.x_scale

    local x_offset = 12
    local y_offset = 2
    x1 = x1 - x_offset
    y1 = y1 - y_offset

    local bar_width = 24*x_scale
    local bar_height = 5
    love.graphics.rectangle("fill", x1, y1, bar_width, bar_height)
  end

  g.pop()
end

return Lifebars


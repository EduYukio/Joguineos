
local Vec = require 'common.vec'
local Cursor = require 'common.class' ()

local CELL_SIZE = 36

function Cursor:_init(battlefield)
  self.position = Vec()
  self.battlefield = battlefield
  self.selected_tower_appearance = nil
end

function Cursor:get_position()
  return self.position:get()
end

function Cursor:update(_)
  local mouse_pos = Vec(love.mouse.getPosition())
  local rounded = self.battlefield:round_to_tile(mouse_pos)
  self.position:set(rounded:get())
end

function Cursor:draw()
  local g = love.graphics
  g.push()
  g.translate(self.position:get())
  local t = math.floor(love.timer.getTime() * 4)
  local color = (t % 2 == 0) and .4 or .2
  g.setColor(1, 1, 1, color)
  g.setLineWidth(2)
  g.rectangle('line', -CELL_SIZE / 2, -CELL_SIZE / 2, CELL_SIZE, CELL_SIZE)

  if self.selected_tower_appearance then
    g.setColor(1, 1, 1, 0.5)
    local tower = require('database.units.' .. self.selected_tower_appearance)
    g.circle("line", 0, 0, tower.range)
  end

  g.pop()
end

return Cursor


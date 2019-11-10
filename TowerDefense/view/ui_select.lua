
local PALETTE_DB = require 'database.palette'
local PROPERTIES_DB = require 'database.properties'
local UI_SELECT_DB = require 'database.ui_select_db'
local Vec = require 'common.vec'
local g = love.graphics

local UI_Select = require 'common.class' ()

function UI_Select:_init(position)
  self.position = position
  self.title_font = g.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.coin_font = g.newFont('assets/fonts/VT323-Regular.ttf', 24)
  self.title_font:setFilter('nearest', 'nearest')
  self.coin_font:setFilter('nearest', 'nearest')

  self.gold = 0
  self.selected_box = nil
  self.hovered_box = nil

  self.sprites = UI_SELECT_DB.sprites
  self.boxes = UI_SELECT_DB.boxes
end

function UI_Select:draw_towers_title()
  g.setFont(self.title_font)
  g.setColor(PALETTE_DB.white)
  g.translate((self.position + Vec(8, -10)):get())
  g.print("Towers:")
end

function UI_Select:draw_upgrades_title()
  g.origin()
  g.translate((self.position + Vec(-4, 265)):get())
  g.print("Upgrades:")
end

function UI_Select:draw_select_boxes(i, box)
  local name = self.sprites[i].name
  local available = self.sprites[i].available
  local cost = PROPERTIES_DB.cost[name]
  local cost_x, cost_y = self.sprites[i].pos:get()
  g.setColor(PALETTE_DB.yellow)
  g.setFont(self.coin_font)
  g.printf(tostring(cost), cost_x - 15, cost_y + 20, 32, "center")

  g.setColor(PALETTE_DB.gray)
  g.setFont(self.title_font)
  g.rectangle('line', box:get_rectangle())
  if not available or self.gold < cost then
    g.setColor(0, 0, 0, 0.7)
    local x, y, w, h = box:get_rectangle()
    g.rectangle('fill', x + 1, y + 1, w - 2, h - 2)
  end
end

function UI_Select:draw()
  g.push()

  self:draw_towers_title()
  self:draw_upgrades_title()
  g.origin()
  for i, box in ipairs(self.boxes) do
    self:draw_select_boxes(i, box)
  end

  if self.hovered_box then
    g.setColor(PALETTE_DB.light_gray)
    g.rectangle('line', self.hovered_box:get_rectangle())
  end

  if self.selected_box then
    g.setColor(PALETTE_DB.pure_white)
    g.rectangle('line', self.selected_box:get_rectangle())
  end

  g.pop()
end

return UI_Select

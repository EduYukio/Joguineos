
local PALETTE_DB = require 'database.palette'
local UI_INFO_DB = require 'database.ui_info_db'
local Vec = require 'common.vec'
local g = love.graphics

local UI_Info = require 'common.class' ()

function UI_Info:_init(position)
  self.position = position
  self.title_font = g.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.text_font = g.newFont('assets/fonts/VT323-Regular.ttf', 24)
  self.small_text_font = g.newFont('assets/fonts/VT323-Regular.ttf', 20)
  self.title_font:setFilter('nearest', 'nearest')
  self.text_font:setFilter('nearest', 'nearest')
  self.small_text_font:setFilter('nearest', 'nearest')

  self.monsters_info = UI_INFO_DB.monsters_info
end

function UI_Info:draw_monster_title()
  g.origin()
  g.translate((self.position + Vec(46, 0)):get())
  g.setColor(PALETTE_DB.pure_white)
  g.setFont(self.title_font)
  g.print("Monsters:")
end

function UI_Info:draw_monster_frame(monster) --luacheck: no self
  g.setColor(PALETTE_DB.pure_white)
  local x, y = monster.pos:get()
  g.rectangle('line', x - 40, y - 55, 220, 115)
end

function UI_Info:draw_monster_box(monster, line_gap) --luacheck: no self
  local x, y = monster.pos:get()
  x = x + 50
  y = y - 42
  g.setColor(PALETTE_DB.pure_white)
  g.print("HP:  " .. monster.hp, x, y)
  g.print("RES: " .. monster.resistance, x, y + line_gap)
  g.print("DMG: " .. monster.damage, x, y + line_gap*2)
  g.print("EVA: " .. monster.damage, x, y + line_gap*3)
end

function UI_Info:draw()
  g.push()
  g.setColor(PALETTE_DB.pure_white)
  g.line(734,40, 734,560)

  self:draw_monster_title()
  g.origin()
  g.setFont(self.text_font)
  local line_gap = 20
  for _, monster in pairs(self.monsters_info) do
    self:draw_monster_frame(monster, line_gap)
    self:draw_monster_box(monster, line_gap)
  end

  g.print("    Monsters don't crit.\nPlayers don't have resistance.", 770, 500)

  g.pop()
end

return UI_Info


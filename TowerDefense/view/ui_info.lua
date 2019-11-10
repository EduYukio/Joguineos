
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

  self.gold = 0
  self.hovered_box = nil
  self.hovered_appearance = nil

  self.towers_info = UI_INFO_DB.towers_info
  self.upgrades_info = UI_INFO_DB.upgrades_info
  self.monsters_info = UI_INFO_DB.monsters_info
end

function UI_Info:draw_information_title()
  g.setColor(PALETTE_DB.white)
  g.translate((self.position + Vec(20, -12)):get())
  g.setFont(self.title_font)
  g.print("Information:")
end

function UI_Info:draw_information_frame() --luacheck: no self
  g.setColor(PALETTE_DB.pure_white)
  g.rectangle('line', -73, 45, 312, 180)
  g.translate(-60, 55)
end

function UI_Info:draw_tower_information(index, line_gap, wrap_limit)
    local info = self.towers_info
    g.printf(info[index].name, 0,-5, wrap_limit, "center")
    g.printf("Damage:  " .. info[index].damage,  0, line_gap,   wrap_limit)
    g.printf("Range:   " .. info[index].range,   0, line_gap*2, wrap_limit)
    g.printf("Targets: " .. info[index].targets, 0, line_gap*3, wrap_limit)
    g.printf("Special: " .. info[index].special, 0, line_gap*4, wrap_limit)
end

function UI_Info:draw_upgrade_information(index, wrap_limit)
  local info = self.upgrades_info
  g.printf(info[index].description, 0, 0, wrap_limit)
end

function UI_Info:draw_information_box()
  g.setColor(PALETTE_DB.white)

  g.setFont(self.text_font)
  local index = self.hovered_appearance
  local wrap_limit = 292
  local line_gap = 25
  if self.hovered_category == "tower" then
    self:draw_tower_information(index, line_gap, wrap_limit)
  elseif self.hovered_category == "upgrade" then
    self:draw_upgrade_information(index, wrap_limit)
  end
end

function UI_Info:draw_monster_title()
  g.origin()
  g.translate((self.position + Vec(46, 220)):get())
  g.setColor(PALETTE_DB.white)
  g.setFont(self.title_font)
  g.print("Monsters:")
end

function UI_Info:draw_monster_frame(monster, line_gap) --luacheck: no self
  g.setColor(PALETTE_DB.pure_white)
  local x, y = monster.pos:get()
  if monster.special then
    g.rectangle('line', x - 22, y - 28, 150, 95)
    g.setColor(PALETTE_DB.white)
    g.print(monster.special, x - 15, y + line_gap)
  else
    g.rectangle('line', x - 22, y - 28, 150, 60)
  end
end

function UI_Info:draw_monster_box(monster, line_gap) --luacheck: no self
  local x, y = monster.pos:get()
  x = x + 27
  y = y - 20
  g.setColor(PALETTE_DB.white)
  g.print("HP:  " .. monster.hp, x, y)
  g.print("SPD: " .. monster.speed, x, y + line_gap)
end

function UI_Info:draw()
  g.push()
  g.setColor(PALETTE_DB.pure_white)
  g.line(734,40, 734,560)

  self:draw_information_title()
  self:draw_information_frame()
  if self.hovered_box then
    self:draw_information_box()
  end

  self:draw_monster_title()
  g.origin()
  g.setFont(self.small_text_font)
  local line_gap = 20
  for _, monster in pairs(self.monsters_info) do
    self:draw_monster_frame(monster, line_gap)
    self:draw_monster_box(monster, line_gap)
  end
  g.pop()
end

return UI_Info


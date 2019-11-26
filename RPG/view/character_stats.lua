
local PALETTE_DB = require 'database.palette'
local g = love.graphics

local CharacterStats = require 'common.class' ()

function CharacterStats:_init(position, character)
  self.position = position
  self.character = character
  self.title_font = g.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.text_font = g.newFont('assets/fonts/VT323-Regular.ttf', 24)
  self.title_font:setFilter('nearest', 'nearest')
  self.text_font:setFilter('nearest', 'nearest')
end

function CharacterStats:draw()
  g.push()

  local char = self.character
  g.translate(self.position:get())

  g.setFont(self.title_font)
  g.setColor(PALETTE_DB.orange)
  g.print(char.name)

  g.translate(0, self.title_font:getHeight())
  g.setFont(self.text_font)

  local line_gap = 20
  g.setColor(PALETTE_DB.blue)
  g.print(("MANA: %d/%d"):format(char.mana, char.max_mana))
  g.setColor(PALETTE_DB.pure_white)
  g.print(("DMG:  %d"):format(char.damage), 0, line_gap)
  g.print(("EVA:  %d%%"):format(char.evasion*100), 0, line_gap*2)
  g.print(("CRI:  %d%%"):format(char.crit_chance*100), 0, line_gap*3)

  g.pop()
end

return CharacterStats


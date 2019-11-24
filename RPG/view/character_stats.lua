
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

  g.setColor(1, 1, 1)
  g.translate(self.position:get())

  g.setFont(self.title_font)
  g.print(self.character.name)

  g.translate(0, self.title_font:getHeight())
  g.setFont(self.text_font)

  local line_gap = 20
  g.print(("DMG: %d"):format(self.character.damage))
  g.print(("EVA: %d%%"):format(self.character.evasion*100), 0, line_gap)
  g.print(("CRI: %d%%"):format(self.character.crit_chance*100), 0, line_gap*2)

  g.pop()
end

return CharacterStats


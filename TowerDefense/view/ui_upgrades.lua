
local UI_Upgrades = require 'common.class' ()
local PALETTE_DB = require 'database.palette'
local Vec = require 'common.vec'

function UI_Upgrades:_init(position)
  self.position = position
  self.font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.font:setFilter('nearest', 'nearest')

  local x0 = 596
  local y0 = 394
  local sq = 32
  local h_gap = sq*1.5
  local v_gap = sq*1.5
  self.sprites = {
    {name = "Archer_Upgrade",  pos = Vec(x0, y0), appearance = "archer2"},
    {name = "Knight_Upgrade",  pos = Vec(x0+h_gap, y0), appearance = "knight2"},
    {name = "Mage_Upgrade",    pos = Vec(x0+h_gap*2, y0), appearance = "mage2"},

    {name = "Castle_Upgrade", pos = Vec(x0+h_gap, y0+v_gap), appearance = "castle2"},
  }
end

function UI_Upgrades:draw()
  local g = love.graphics
  g.push()
  g.setFont(self.font)
  g.setColor(PALETTE_DB.white)
  g.translate((self.position+Vec(-4,0)):get())
  g.print("Upgrades:")
  g.translate(-6, self.font:getHeight())

  local first_x = 16
  local first_y = 16
  local w,h = 36,36

  g.rectangle("line", 0, 16, w, h )
  g.rectangle("line", first_x*3, first_y, w, h )
  g.rectangle("line", first_x*6, first_y, w, h )

  g.rectangle("line", first_x*3, first_y*4, w, h )

  g.pop()
end

return UI_Upgrades


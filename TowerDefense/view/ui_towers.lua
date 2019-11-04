
local UI_Towers = require 'common.class' ()
local PALETTE_DB = require 'database.palette'
local Vec = require 'common.vec'

function UI_Towers:_init(position)
  self.position = position
  self.font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.font:setFilter('nearest', 'nearest')

  local x0 = 596
  local y0 = 171
  local sq = 32
  local h_gap = sq*1.5
  local v_gap = sq*1.5
  self.sprites = {
    {name = "UI_Archer",  pos = Vec(x0, y0), appearance = "archer1"},
    {name = "UI_Knight",  pos = Vec(x0+h_gap, y0), appearance = "knight1"},
    {name = "UI_Mage",    pos = Vec(x0+h_gap*2, y0), appearance = "mage1"},

    {name = "UI_Sword",   pos = Vec(x0, y0+v_gap), appearance = "sword"},
    {name = "UI_Cthullu", pos = Vec(x0+h_gap, y0+v_gap), appearance = "cthullu"},
    {name = "UI_Ghost",   pos = Vec(x0+h_gap*2, y0+v_gap), appearance = "ghost"},

    {name = "UI_Farmer",  pos = Vec(x0+h_gap, y0+v_gap*2), appearance = "farmer"},
  }
end

function UI_Towers:draw()
  local g = love.graphics
  g.push()
  g.setFont(self.font)
  g.setColor(PALETTE_DB.white)
  g.translate((self.position+Vec(8,0)):get())
  g.print("Towers:")
  g.translate(-18, self.font:getHeight())

  local first_x = 16
  local first_y = 16
  local w,h = 36,36

  g.rectangle("line", 0, 16, w, h )
  g.rectangle("line", first_x*3, first_y, w, h )
  g.rectangle("line", first_x*6, first_y, w, h )

  g.rectangle("line", 0, first_y*4, w, h )
  g.rectangle("line", first_x*3, first_y*4, w, h )
  g.rectangle("line", first_x*6, first_y*4, w, h )

  g.rectangle("line", first_x*3, first_y*7, w, h )
  g.pop()
end

return UI_Towers


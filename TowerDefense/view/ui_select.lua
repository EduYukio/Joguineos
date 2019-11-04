
local UI_Select = require 'common.class' ()
local PALETTE_DB = require 'database.palette'
local Vec = require 'common.vec'
local Box = require 'common.box'

function UI_Select:_init(position)
  self.position = position
  self.font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.font:setFilter('nearest', 'nearest')

  local x0 = 596
  local y0 = 171
  local y00 = 394
  local sq = 32
  local h_gap = sq*1.5
  local v_gap = sq*1.5
  self.sprites = {
    {
      name = "UI_Archer",
      pos = Vec(x0, y0),
      appearance = "archer1",
      category = "tower",
    },
    {
      name = "UI_Knight",
      pos = Vec(x0+h_gap, y0),
      appearance = "knight1",
      category = "tower",
    },
    {
      name = "UI_Mage",
      pos = Vec(x0+h_gap*2, y0),
      appearance = "mage1",
      category = "tower",
    },
    {
      name = "UI_Sword",
      pos = Vec(x0, y0+v_gap),
      appearance = "sword",
      category = "tower",
    },
    {
      name = "UI_Cthullu",
      pos = Vec(x0+h_gap, y0+v_gap),
      appearance = "cthullu",
      category = "tower",
    },
    {
      name = "UI_Ghost",
      pos = Vec(x0+h_gap*2, y0+v_gap),
      appearance = "ghost",
      category = "tower",
    },
    {
      name = "UI_Farmer",
      pos = Vec(x0+h_gap, y0+v_gap*2),
      appearance = "farmer",
      category = "tower",
    },


    {
      name = "Archer_Upgrade",
      pos = Vec(x0, y00),
      appearance = "archer2",
      category = "upgrade",
    },
    {
      name = "Knight_Upgrade",
      pos = Vec(x0+h_gap, y00),
      appearance = "knight2",
      category = "upgrade",
    },
    {
      name = "Mage_Upgrade",
      pos = Vec(x0+h_gap*2, y00),
      appearance = "mage2",
      category = "upgrade",
    },
    {
      name = "Castle_Upgrade",
      pos = Vec(x0+h_gap, y00+v_gap),
      appearance = "castle2",
      category = "upgrade",
    },
  }
  local halfsize = Vec(18,19)
  self.boxes = {
    Box.from_vec(Vec(x0, y0),             halfsize),
    Box.from_vec(Vec(x0+h_gap, y0),       halfsize),
    Box.from_vec(Vec(x0+h_gap*2, y0),     halfsize),
    Box.from_vec(Vec(x0, y0+v_gap),       halfsize),
    Box.from_vec(Vec(x0+h_gap, y0+v_gap), halfsize),
    Box.from_vec(Vec(x0+h_gap*2, y0+v_gap), halfsize),
    Box.from_vec(Vec(x0+h_gap, y0+v_gap*2), halfsize),


    Box.from_vec(Vec(x0, y00),              halfsize),
    Box.from_vec(Vec(x0+h_gap, y00),        halfsize),
    Box.from_vec(Vec(x0+h_gap*2, y00),      halfsize),
    Box.from_vec(Vec(x0+h_gap, y00+v_gap),  halfsize),
  }
end

function UI_Select:draw()
  local g = love.graphics
  g.push()
  g.setFont(self.font)
  g.setColor(PALETTE_DB.white)
  g.translate((self.position+Vec(8,0)):get())
  g.print("Towers:")
  love.graphics.origin()
  g.translate((self.position+Vec(-4,220)):get())
  g.print("Upgrades:")
  love.graphics.origin()

  g.setColor(PALETTE_DB.gray)
  for _, v in ipairs(self.boxes) do
    g.rectangle('line', v:get_rectangle())
  end

  g.pop()
end

return UI_Select


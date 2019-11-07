
local UI_Select = require 'common.class' ()
local PALETTE_DB = require 'database.palette'
local Vec = require 'common.vec'
local Box = require 'common.box'
local p = require 'database.properties'

function UI_Select:_init(position)
  self.position = position
  self.title_font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.coin_font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 24)

  self.title_font:setFilter('nearest', 'nearest')
  self.coin_font:setFilter('nearest', 'nearest')
  self.gold = 0

  local x0 = 596
  local y0 = 151
  local y00 = 430
  local sq = 32
  local h_gap = sq*1.5
  local v_gap = sq*2.5
  self.sprites = {
    {
      name = "Archer",
      pos = Vec(x0, y0),
      appearance = "archer1",
      category = "tower",
      available = true,
    },
    {
      name = "Knight",
      pos = Vec(x0+h_gap, y0),
      appearance = "knight1",
      category = "tower",
      available = true,
    },
    {
      name = "Mage",
      pos = Vec(x0+h_gap*2, y0),
      appearance = "mage1",
      category = "tower",
      available = true,
    },
    {
      name = "Sword",
      pos = Vec(x0, y0+v_gap),
      appearance = "sword",
      category = "tower",
      available = true,
    },
    {
      name = "Cthullu",
      pos = Vec(x0+h_gap, y0+v_gap),
      appearance = "cthullu",
      category = "tower",
      available = true,
    },
    {
      name = "Ghost",
      pos = Vec(x0+h_gap*2, y0+v_gap),
      appearance = "ghost",
      category = "tower",
      available = true,
    },
    {
      name = "Farmer",
      pos = Vec(x0+h_gap, y0+v_gap*2),
      appearance = "farmer",
      category = "tower",
      available = true,
    },


    {
      name = "Archer_Upgrade",
      pos = Vec(x0, y00),
      appearance = "archer2",
      category = "upgrade",
      available = true,
    },
    {
      name = "Knight_Upgrade",
      pos = Vec(x0+h_gap, y00),
      appearance = "knight2",
      category = "upgrade",
      available = true,
    },
    {
      name = "Mage_Upgrade",
      pos = Vec(x0+h_gap*2, y00),
      appearance = "mage2",
      category = "upgrade",
      available = true,
    },
    {
      name = "Castle_Upgrade",
      pos = Vec(x0+h_gap, y00+v_gap),
      appearance = "castle2",
      category = "upgrade",
      available = true,
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

  self.selected_box = nil
  self.hovered_box = nil
end

function UI_Select:draw()
  local g = love.graphics
  g.push()
  g.setFont(self.title_font)
  g.setColor(PALETTE_DB.white)
  g.translate((self.position+Vec(8, -10)):get())
  g.print("Towers:")
  love.graphics.origin()
  g.translate((self.position+Vec(-4, 265)):get())
  g.print("Upgrades:")
  love.graphics.origin()

  for i, box in ipairs(self.boxes) do
    local name = self.sprites[i].name
    local available = self.sprites[i].available
    local cost = p.cost[name]
    local cost_x, cost_y = self.sprites[i].pos:get()
    g.setColor(PALETTE_DB.yellow)
    g.setFont(self.coin_font)
    g.printf(tostring(cost), cost_x-15, cost_y+20, 32, "center")

    g.setColor(PALETTE_DB.gray)
    g.setFont(self.title_font)
    g.rectangle('line', box:get_rectangle())
    if not available or self.gold < cost then
      g.setColor(0, 0, 0, 0.7)
      local x, y, w, h = box:get_rectangle()
      g.rectangle('fill', x+1, y+1, w-2,h-2)
    end
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


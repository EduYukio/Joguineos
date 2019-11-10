
local Box = require 'common.box'
local Vec = require 'common.vec'

local x0 = 596
local y0 = 151
local y00 = 430
local sq = 32
local h_gap = sq*1.5
local v_gap = sq*2.5
local halfsize = Vec(18,19)

return {
  sprites = {
    {
      name = "Archer",
      pos = Vec(x0, y0),
      appearance = "archer1",
      category = "tower",
      available = true,
    },
    {
      name = "Knight",
      pos = Vec(x0 + h_gap, y0),
      appearance = "knight1",
      category = "tower",
      available = true,
    },
    {
      name = "Mage",
      pos = Vec(x0 + h_gap*2, y0),
      appearance = "mage1",
      category = "tower",
      available = true,
    },
    {
      name = "Sword",
      pos = Vec(x0, y0 + v_gap),
      appearance = "sword",
      category = "tower",
      available = true,
    },
    {
      name = "Cthullu",
      pos = Vec(x0 + h_gap, y0 + v_gap),
      appearance = "cthullu",
      category = "tower",
      available = true,
    },
    {
      name = "Ghost",
      pos = Vec(x0 + h_gap*2, y0 + v_gap),
      appearance = "ghost",
      category = "tower",
      available = true,
    },
    {
      name = "Farmer",
      pos = Vec(x0 + h_gap, y0 + v_gap*2),
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
      pos = Vec(x0 + h_gap, y00),
      appearance = "knight2",
      category = "upgrade",
      available = true,
    },
    {
      name = "Mage_Upgrade",
      pos = Vec(x0 + h_gap*2, y00),
      appearance = "mage2",
      category = "upgrade",
      available = true,
    },
    {
      name = "Castle_Upgrade",
      pos = Vec(x0 + h_gap, y00+v_gap),
      appearance = "castle2",
      category = "upgrade",
      available = true,
    },
  },
  boxes = {
    Box.from_vec(Vec(x0, y0),                   halfsize),
    Box.from_vec(Vec(x0 + h_gap, y0),           halfsize),
    Box.from_vec(Vec(x0 + h_gap*2, y0),         halfsize),
    Box.from_vec(Vec(x0, y0 + v_gap),           halfsize),
    Box.from_vec(Vec(x0 + h_gap, y0 + v_gap),   halfsize),
    Box.from_vec(Vec(x0 + h_gap*2, y0 + v_gap), halfsize),
    Box.from_vec(Vec(x0 + h_gap, y0 + v_gap*2), halfsize),

    Box.from_vec(Vec(x0, y00),                  halfsize),
    Box.from_vec(Vec(x0 + h_gap, y00),          halfsize),
    Box.from_vec(Vec(x0 + h_gap*2, y00),        halfsize),
    Box.from_vec(Vec(x0 + h_gap, y00 + v_gap),  halfsize),
  },
}
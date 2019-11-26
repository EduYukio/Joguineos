
local Vec = require 'common.vec'

local x0 = 885
local y0 = 145
local sq = 32
local v_gap = 25  + sq*3.5

return {
  monsters_info = {
    slime = {
      name = "Slime",
      hp = "Low",
      resistance = "Medium",
      damage = "Medium",
      evasion = "Medium",
      pos = Vec(x0, y0),
      appearance = "slime",
    },
    golem = {
      name = "Golem",
      hp = "High",
      resistance = "High",
      damage = "Low",
      evasion = "Low",
      pos = Vec(x0, y0 + v_gap),
      appearance = "golem",
    },
    ninja = {
      name = "Ninja",
      hp = "Medium",
      resistance = "Low",
      damage = "High",
      evasion = "High",
      pos = Vec(x0, y0 + 2*v_gap),
      appearance = "ninja",
    },
  },
}

local Vec = require 'common.vec'

local x0 = 775
local y0 = 345
local sq = 32
local h_gap = 115 + sq*1.5
local v_gap = 25  + sq*1.5

return {
  towers_info = {
    archer1 = {
      name = "Archer",
      damage = "Low",
      range = "High",
      targets = "1",
      special = "None",
    },
    knight1 = {
      name = "Knight",
      damage = "High",
      range = "Low",
      targets = "1",
      special = "None",
    },
    mage1 = {
      name = "Mage",
      damage = "Medium",
      range = "Medium",
      targets = "3",
      special = "None",
    },
    sword = {
      name = "Sword",
      damage = "None",
      range = "1 square",
      targets = "1",
      special = "Increases the damage of a tower",
    },
    cthullu = {
      name = "Cthullu",
      damage = "None",
      range = "Medium",
      targets = "3",
      special = "Slows enemies a bit",
    },
    ghost = {
      name = "Ghost",
      damage = "None",
      range = "Medium",
      targets = "1",
      special = "Slows enemies a lot",
    },
    farmer = {
      name = "Farmer",
      damage = "None",
      range = "None",
      targets = "None",
      special = "Produces 1 gold each 7 seconds",
    },
    archer2 = {
      name = "Marksman",
      damage = "Medium",
      range = "High",
      targets = "1",
      special = "None",
    },
    knight2 = {
      name = "Elite Knight",
      damage = "Huge",
      range = "Low",
      targets = "1",
      special = "None",
    },
    mage2 = {
      name = "Archmage",
      damage = "High",
      range = "Medium",
      targets = "3",
      special = "None",
    },
  },
  upgrades_info = {
    archer2 = {
      name = "Archer_Upgrade",
      description = "Turns all Archers into Marksmen, increasing their damage",
    },
    knight2 = {
      name = "Knight_Upgrade",
      description = "Turns all Knights into Elite Knights, increasing their damage",
    },
    mage2 = {
      name = "Mage_Upgrade",
      description = "Turns all Mages into Archmages, increasing their damage",
    },
    castle2 = {
      name = "Castle_Upgrade",
      description = "Replenish castle's health and increases it",
    },
  },
  monsters_info = {
    slime = {
      name = "Slime",
      hp = "Low",
      speed = "Medium",
      pos = Vec(x0, y0),
      appearance = "slime",
    },
    bat = {
      name = "Bat",
      hp = "Low",
      speed = "Fast",
      pos = Vec(x0 + h_gap, y0),
      appearance = "bat",
    },
    golem = {
      name = "Golem",
      hp = "Medium",
      speed = "Low",
      pos = Vec(x0 + h_gap/2, y0 + v_gap),
      appearance = "golem",
    },
    blinker = {
      name = "Blinker",
      hp = "High",
      speed = "None",
      special = "    Teleports\n(can't be slowed)",
      pos = Vec(x0, y0 + v_gap*2),
      appearance = "blinker",
    },
    summoner = {
      name = "Summoner",
      hp = "Huge",
      speed = "Low",
      special = "     Summons\n   4 weaklings",
      pos = Vec(x0 + h_gap, y0 + v_gap*2),
      appearance = "summoner",
    },
  },
}
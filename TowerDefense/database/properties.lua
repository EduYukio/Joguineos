
local square = 32
local diagonal_offset = 14

return {
  damage = {
    none = 0,
    low = 2/60,
    medium = 4/60,
    high = 7/60,
  },
  hp = {
    low = 20,
    medium = 150,
    high = 210,
    very_high = 320,
  },
  speed = {
    none = 0,
    low = 15,
    medium = 30,
    high = 50,
  },
  target_policy = {
    none = 0,
    single = 1,
    multiple = 3,
  },
  range = {
    none   = 0,
    one    = 0.1 + square + diagonal_offset,
    low    = 0.1 + square*1.85,
    medium = 0.1 + square*4,
    high   = 0.1 + square*7,
  },
  slow_factor = {
    medium = 1.5,
    high = 3,
  },
  castle_hp = {
    normal = 7,
    upgraded = 10,
  },
  farm = {
    gold_to_produce = 1,
    gold_making_delay = 7,
  },
  cost = {
    Archer  = 5,
    Knight  = 10,
    Mage    = 15,
    Sword   = 30,
    Cthullu = 35,
    Ghost   = 35,
    Farmer  = 15,
    Archer_Upgrade = 50,
    Knight_Upgrade = 50,
    Mage_Upgrade   = 50,
    Castle_Upgrade = 50,
  },
  reward = {
    slime    = 1,
    bat      = 1,
    golem    = 3,
    blinker  = 4,
    summoner = 5,
    bee      = 0,
    beetle   = 0,
    scorpion = 0,
    spider   = 0,
  },
  upgrade_dmg = 2/60,
  buff_factor = 5,
  blink_steps = 5,
  blink_delay = 3.5,
  summon_delay = 7,
  summons = {
    "scorpion", "bee", "beetle", "spider"
  }
}


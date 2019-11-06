local square = 32
local diagonal_offset = 14

return {
  damage = {
    none = 0,
    low = 1.5/60,
    medium = 3/60,
    high = 7/60,
  },
  hp = {
    low = 20,
    medium = 150,
    high = 210,
  },
  speed = {
    none = 0,
    low = 15,
    medium = 25,
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
    low    = 0.1 + square*2,
    medium = 0.1 + square*4,
    high   = 0.1 + square*10,
  },
  slow_factor = {
    medium = 1.5,
    high = 3,
  },
  castle_hp = {
    normal = 7,
    upgraded = 15,
  },
  farm = {
    gold_to_produce = 3,
    gold_making_delay = 4,
  },
  cost = {
    Archer  = 10,
    Knight  = 15,
    Mage    = 20,
    Sword   = 50,
    Cthullu = 50,
    Ghost   = 50,
    Farmer  = 20,
    Archer_Upgrade = 100,
    Knight_Upgrade = 150,
    Mage_Upgrade   = 200,
    Castle_Upgrade = 100,
  },
  reward = {
    slime    = 3,
    bat      = 3,
    golem    = 10,
    blinker  = 15,
    summoner = 15,
    bee      = 3,
    beetle   = 3,
    scorpion = 3,
    spider   = 3,
  },
  buff_factor = 0.25,
  blink_steps = 5,
  blink_delay = 1.5,
  summon_delay = 3,
  summons = {
    "scorpion", "bee", "beetle", "spider"
  }
}


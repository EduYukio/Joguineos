local square = 32
local diagonal_offset = 14

return {
  damage = {
    none = 0,
    low = 1/60,
    medium = 4/60,
    high = 10/60,
    very_high = 15/60,
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
  speed = {
    none = 0,
    low = 10,
    medium = 20,
    high = 50,
  },
  hp = {
    low = 10,
    medium = 25,
    high = 50,
  },
  castle_hp = {
    normal = 5,
    upgraded = 10,
  },
  farm = {
    gold_to_produce = 2,
    gold_making_delay = 5,
  },
  cost = {
    Archer = 10,
    Knight = 30,
    Mage   = 50,
    Sword   = 20,
    Cthullu = 50,
    Ghost   = 50,
    Farmer  = 100,
    Archer_Upgrade = 100,
    Knight_Upgrade = 250,
    Mage_Upgrade   = 350,
    Castle_Upgrade = 400,
  },
  buff_factor = 0.25,
  blink_steps = 5,
  blink_delay = 1.5,
  summon_delay = 3,
  summons = {
    "scorpion", "bee", "beetle", "spider"
  }
}


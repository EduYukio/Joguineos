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
  target = {
    none = 0,
    single = 1,
    multiple = 3,
  },
  range = {
    none   = 0,
    one    = 0.1 + square + diagonal_offset,
    low    = 0.1 + square*2,
    medium = 0.1 + square*4,
    high   = 0.1 + square*8,
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
  buff_factor = 0.25,
  gold_to_produce = 1,
  blink_distance = 32*3,
  blink_delay = 1.5,
  summon_delay = 3.5,
}


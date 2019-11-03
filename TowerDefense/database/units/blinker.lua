
local p = require 'database.properties'

return {
  name = "Blinker",
  max_hp = p.hp.medium,
  speed = p.speed.none,
  special = {
    blink_distance = p.blink_distance,
    blink_delay = p.blink_delay,
  },
  appearance = 'blinker',
  category = "monster"
}


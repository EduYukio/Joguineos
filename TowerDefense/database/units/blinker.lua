
local p = require 'database.properties'

return {
  name = "Blinker",
  max_hp = p.hp.medium,
  speed = p.speed.none,
  special = {
    blink_steps = p.blink_steps,
    blink_delay = p.blink_delay,
  },
  appearance = 'blinker',
  category = "monster"
}


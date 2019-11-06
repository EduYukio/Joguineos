
local p = require 'database.properties'

return {
  name = "Blinker",
  max_hp = p.hp.high,
  speed = p.speed.none,
  special = {
    blink_steps = p.blink_steps,
    blink_delay = p.blink_delay,
  },
  reward = p.reward.blinker,
  appearance = 'blinker',
  category = "monster"
}


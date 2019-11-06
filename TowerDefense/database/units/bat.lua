
local p = require 'database.properties'

return {
  name = "Bat",
  appearance = 'bat',
  max_hp = p.hp.low,
  speed = p.speed.high,
  reward = p.reward.bat,
  category = "monster"
}


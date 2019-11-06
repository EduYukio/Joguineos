
local p = require 'database.properties'

return {
  name = "Golem",
  max_hp = p.hp.medium,
  speed = p.speed.low,
  reward = p.reward.golem,
  appearance = 'golem',
  category = "monster"
}


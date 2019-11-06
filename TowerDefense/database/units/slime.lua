
local p = require 'database.properties'

return {
  name = "Slime",
  max_hp = p.hp.low,
  speed = p.speed.low,
  reward = p.reward.slime,
  appearance = 'slime',
	category = "monster"
}


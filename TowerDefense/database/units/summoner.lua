
local p = require 'database.properties'

return {
  name = "Summoner",
  max_hp = p.hp.very_high,
  speed = p.speed.low,
  special = {
    summon_delay = p.summon_delay,
    summons = p.summons,
  },
  reward = p.reward.summoner,
  appearance = 'summoner',
	category = "monster"
}


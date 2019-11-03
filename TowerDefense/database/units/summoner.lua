
local p = require 'database.properties'

return {
  name = "Summoner",
  max_hp = p.hp.medium,
  speed = p.speed.low,
  special = {
    summon_delay = p.summon_delay,
  },
  appearance = 'summoner',
	category = "monster"
}


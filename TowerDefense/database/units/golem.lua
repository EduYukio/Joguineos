
local p = require 'database.properties'

return {
  name = "Golem",
  max_hp = p.hp.high,
  speed = p.speed.low,
  appearance = 'golem',
  category = "monster"
}


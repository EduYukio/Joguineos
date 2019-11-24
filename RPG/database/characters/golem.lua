
local p = require 'database.properties'

return {
  name = "Golem",
  appearance = 'golem',
  max_hp = p.hp.high,
  damage = p.damage.low,
  resistance = p.resistance.high,
  category = "monster",
}



local p = require 'database.properties'

return {
  name = "Slime",
  appearance = 'slime',
  max_hp = p.hp.low,
  damage = p.damage.medium,
  resistance = p.resistance.medium,
  category = "monster",
}


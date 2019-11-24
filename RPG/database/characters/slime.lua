
local p = require 'database.properties'

return {
  name = "Slime",
  appearance = 'slime',
  max_hp = p.hp.low,
  damage = p.damage.medium,
  resistance = p.resistance.medium,
  evasion = p.evasion.medium,
  crit_chance = p.crit_chance.none,
  category = "monster",
}



local p = require 'database.properties'

return {
  name = "Ninja",
  appearance = 'ninja',
  max_hp = p.hp.medium,
  damage = p.damage.high,
  resistance = p.resistance.low,
  evasion = p.evasion.high,
  crit_chance = p.crit_chance.none,
  max_mana = p.mana.none,
  category = "monster",
}


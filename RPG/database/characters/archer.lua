
local p = require 'database.properties'

return {
  name = "Archer",
  appearance = 'archer',
  max_hp = p.hp.medium*2,
  damage = p.damage.high*2,
  resistance = p.resistance.none,
  evasion = p.evasion.medium,
  crit_chance = p.crit_chance.high,
  max_mana = p.mana.medium,
  category = "player",
}


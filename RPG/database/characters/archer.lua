
local p = require 'database.properties'

return {
  name = "Archer",
  appearance = 'archer',
  max_hp = p.hp.medium,
  damage = p.damage.high+5,
  resistance = p.resistance.none,
  evasion = p.evasion.medium,
  crit_chance = p.crit_chance.high,
  max_mana = p.mana.medium,
  skill_set = p.skill_set.archer,
  category = "player",
}



local p = require 'database.properties'

return {
  name = "Priest",
  appearance = 'priest',
  max_hp = p.hp.medium,
  damage = p.damage.low+5,
  resistance = p.resistance.none,
  evasion = p.evasion.medium,
  crit_chance = p.crit_chance.low,
  max_mana = p.mana.high,
  skill_set = p.skill_set.priest,
  category = "player",
}


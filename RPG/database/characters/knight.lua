
local p = require 'database.properties'

return {
  name = "Knight",
  appearance = 'knight',
  max_hp = p.hp.high,
  damage = p.damage.medium+5,
  resistance = p.resistance.none,
  evasion = p.evasion.low,
  crit_chance = p.crit_chance.medium,
  max_mana = p.mana.low,
  skill_set = p.skill_set.knight,
  category = "player",
}


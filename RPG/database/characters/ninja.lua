
local p = require 'database.properties'

return {
  name = "Ninja",
  appearance = 'ninja',
  max_hp = p.hp.medium,
  damage = p.damage.high,
  resistance = p.resistance.low,
  evasion = p.evasion.high,
  category = "monster",
}


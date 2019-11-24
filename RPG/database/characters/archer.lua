
local p = require 'database.properties'

return {
  name = "Archer",
  appearance = 'archer',
  max_hp = p.hp.medium*2,
  damage = p.damage.high*2,
  resistance = p.resistance.none,
  category = "player",
}


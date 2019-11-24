
local p = require 'database.properties'

return {
  name = "Knight",
  appearance = 'knight',
  max_hp = p.hp.high*2,
  damage = p.damage.medium*2,
  resistance = p.resistance.none,
  category = "player",
}


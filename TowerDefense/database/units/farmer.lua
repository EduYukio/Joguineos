
local p = require 'database.properties'

return {
  name = "Farmer",
  appearance = 'farmer',
  range = p.range.none,
  damage = p.damage.none,
  target = p.target.none,
  special = {
    farm = p.gold_to_produce,
  },
  category = "tower"
}


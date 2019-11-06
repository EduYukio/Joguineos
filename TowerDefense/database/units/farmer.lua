
local p = require 'database.properties'

return {
  name = "Farmer",
  appearance = 'farmer',
  cost = p.cost.Farmer,
  range = p.range.none,
  damage = p.damage.none,
  target_policy = p.target_policy.none,
  special = {
    gold_to_produce = p.farm.gold_to_produce,
    gold_making_delay = p.farm.gold_making_delay,
  },
  category = "tower"
}


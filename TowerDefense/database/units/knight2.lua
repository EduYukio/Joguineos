
local p = require 'database.properties'

return {
  name = "Knight",
  appearance = 'knight2',
  cost = p.cost.Knight,
  range = p.range.low,
  damage = p.damage.very_high,
  target_policy = p.target_policy.single,
	category = "tower"
}


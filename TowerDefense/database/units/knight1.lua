
local p = require 'database.properties'

return {
  name = "Knight",
  appearance = 'knight1',
  cost = p.cost.Knight,
  range = p.range.low,
  damage = p.damage.high,
  target_policy = p.target_policy.single,
	category = "tower"
}


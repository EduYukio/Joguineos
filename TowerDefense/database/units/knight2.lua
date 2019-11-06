
local p = require 'database.properties'

return {
  name = "Knight",
  appearance = 'knight2',
  cost = p.cost.Knight,
  range = p.range.low,
  damage = p.damage.high*1.5,
  target_policy = p.target_policy.single,
	category = "tower"
}


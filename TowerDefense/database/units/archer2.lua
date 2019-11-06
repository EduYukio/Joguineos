
local p = require 'database.properties'

return {
  name = "Archer",
  appearance = 'archer2',
  cost = p.cost.Archer,
  range = p.range.high,
  damage = p.damage.medium,
  target_policy = p.target_policy.single,
	category = "tower",
}



local p = require 'database.properties'

return {
  name = "Archer",
  appearance = 'archer1',
  range = p.range.high,
  damage = p.damage.low,
  target_policy = p.target_policy.single,
	category = "tower",
}


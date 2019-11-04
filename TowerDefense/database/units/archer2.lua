
local p = require 'database.properties'

return {
  name = "Archer Upgraded",
  appearance = 'archer2',
  range = p.range.high,
  damage = p.damage.medium,
  target_policy = p.target_policy.single,
	category = "tower",
}


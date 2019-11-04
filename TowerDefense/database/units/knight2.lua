
local p = require 'database.properties'

return {
  name = "Knight Upgraded",
  appearance = 'knight2',
  range = p.range.low,
  damage = p.damage.very_high,
  target_policy = p.target_policy.single,
	category = "tower"
}


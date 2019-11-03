
local p = require 'database.properties'

return {
  name = "Knight Upgraded",
  appearance = 'knight2',
  range = p.range.low,
  damage = p.damage.very_high,
  target = p.target.single,
	category = "tower"
}


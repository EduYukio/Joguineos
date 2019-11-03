
local p = require 'database.properties'

return {
  name = "Knight",
  appearance = 'knight1',
  range = p.range.low,
  damage = p.damage.high,
  target = p.target.single,
	category = "tower"
}


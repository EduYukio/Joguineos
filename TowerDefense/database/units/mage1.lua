
local p = require 'database.properties'

return {
  name = "Mage",
  appearance = 'mage1',
  range = p.range.medium,
  damage = p.damage.medium,
  target = p.target.aoe,
	category = "tower"
}



local p = require 'database.properties'

return {
  name = "Mage",
  appearance = 'mage1',
  range = p.range.medium,
  damage = p.damage.medium,
  target_policy = p.target_policy.multiple,
	category = "tower"
}



local p = require 'database.properties'

return {
  name = "Mage Upgraded",
  appearance = 'mage2',
  range = p.range.medium,
  damage = p.damage.high,
  target_policy = p.target_policy.multiple,
	category = "tower"
}


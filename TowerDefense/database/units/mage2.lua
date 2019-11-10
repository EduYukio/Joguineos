
local p = require 'database.properties'

return {
  name = "Mage",
  appearance = 'mage2',
  cost = p.cost.Mage,
  range = p.range.medium,
  damage = p.damage.medium + p.upgrade_dmg,
  target_policy = p.target_policy.multiple,
	category = "tower"
}


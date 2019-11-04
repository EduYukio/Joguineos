
local p = require 'database.properties'

return {
  name = "Cthullu",
  appearance = 'cthullu',
  range = p.range.medium,
  damage = p.damage.none,
  target = p.target.multiple,
  special = {
    slow = p.slow_factor.medium,
  },
  category = "tower"
}


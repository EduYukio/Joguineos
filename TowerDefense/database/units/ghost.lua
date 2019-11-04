
local p = require 'database.properties'

return {
  name = "Ghost",
  appearance = 'ghost',
  range = p.range.medium,
  damage = p.damage.none,
  target = p.target.single,
  special = {
    slow = p.slow_factor.high,
  },
  category = "tower"
}


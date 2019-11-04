
local p = require 'database.properties'

return {
  name = "Ghost",
  appearance = 'ghost',
  range = p.range.medium,
  damage = p.damage.none,
  target_policy = p.target_policy.single,
  special = {
    slow = p.slow_factor.high,
  },
  category = "tower"
}


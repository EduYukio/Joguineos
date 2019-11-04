
local p = require 'database.properties'

return {
  name = "Sword",
  appearance = 'sword',
  range = p.range.one,
  damage = p.damage.none,
  target_policy = p.target_policy.single,
  special = {
    buff = p.buff_factor,
  },
  category = "tower"
}


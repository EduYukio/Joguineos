
local p = require 'database.properties'

return {
  name = "Sword",
  appearance = 'sword',
  range = p.range.medium,
  damage = p.damage.none,
  target = p.target.single,
  special = {
    buff = p.buff_factor,
  },
  category = "tower"
}


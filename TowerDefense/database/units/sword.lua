
local p = require 'database.properties'

return {
  name = "Sword",
  appearance = 'sword',
  range = p.range.one,
  damage = p.damage.none,
  target = p.target.single,
  special = {
    buff = p.dmg_buff_factor,
  },
  category = "tower"
}


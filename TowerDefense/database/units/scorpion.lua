
local p = require 'database.properties'
local Vec = require 'common.vec'

return {
  name = "Scorpion",
  max_hp = p.hp.low,
  speed = p.speed.low,
  special = {
    spawn_position = Vec(-14, -19),
  },
  appearance = 'scorpion',
  category = "monster"
}

local p = require 'database.properties'
local Vec = require 'common.vec'

return {
  name = "Beetle",
  max_hp = p.hp.low,
  speed = p.speed.low,
  special = {
    spawn_position = Vec(-18, 34),
  },
  appearance = 'beetle',
  category = "monster"
}
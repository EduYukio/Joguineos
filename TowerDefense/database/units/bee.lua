
local p = require 'database.properties'
local Vec = require 'common.vec'

return {
  name = "Bee",
  max_hp = p.hp.low,
  speed = p.speed.low,
  special = {
    spawn_position = Vec(14, -19),
  },
  reward = p.reward.bee,
  appearance = 'bee',
  category = "monster"
}
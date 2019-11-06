
local p = require 'database.properties'
local Vec = require 'common.vec'

return {
  name = "Spider",
  max_hp = p.hp.low,
  speed = p.speed.low,
  special = {
    spawn_position = Vec(14, 30),
  },
  reward = p.reward.spider,
  appearance = 'spider',
  category = "monster"
}
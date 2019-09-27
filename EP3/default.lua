local Vec = require 'common/vec' ()

return {
  position = {
    point = Vec(0, 0)
  },
  movement = {
    motion = Vec(0, 0)
  },
  body = {
    size = 8
  },
  control = {
    acceleration = 0.0,
    max_speed = 50.0,
  },
  field = {
    strength = 1
  },
  charge = {
    strength = 1
  }
}

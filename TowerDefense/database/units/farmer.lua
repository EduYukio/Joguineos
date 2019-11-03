
local p = require 'database.properties'

return {
  name = "Farmer",
  appearance = 'farmer',
  special = {
    p.gold_to_produce,
  },
  category = "tower"
}


-- luacheck: no global

-- local simulator = require "simulator"

function love.draw()
	local input = {
		units = {
		  Ike = {
		    hp = 50, str = 30, mag = 5, skl = 28,
		    spd = 24, def = 28, res = 15, lck = 12,
		    weapon = "steel blade"
		  },
		  Soren = {
		    hp = 32, str = 14, mag = 30, skl = 32,
		    spd = 28, def = 12, res = 22, lck = 16,
		    weapon = "elwind"
		  },
		  Brigand = {
		    hp = 40, str = 16, mag = 0, skl = 12,
		    spd = 12, def = 10, res = 0, lck = 0,
		    weapon = "iron axe"
		  },
		}
	}

	local output = {
	  units = {
	  }
	}

	-- output.units["Ike"] = {hp = 5}
	local x = 25
	for name, stats in pairs(input.units) do
	  x = x+25
	  -- love.graphics.print(stats.hp, 400, 300+x)
	  output.units[name] = stats.hp
	  love.graphics.print(output.units[name], 400, 300+x)
	end

  -- love.graphics.print(output.units["Ike"].hp, 400, 300)
end
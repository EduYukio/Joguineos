
local SIMULATOR = {}

function SIMULATOR.run(scenario_input)
  local fights = scenario_input.fights

  for attacker, defender in pairs(fights) do
    -- local attacker = k
    -- local defender = v
    SIMULATOR.round(attacker, defender)
  end

  return scenario_input.output.units
end

function SIMULATOR.round(attacker, defender)
  attacker:attack(defender)
  defender:attack(attacker)
end

function SIMULATOR.attack(unit)
end

function SIMULATOR.calculateTriangleBonus(attackWeapon, defenseWeapon)
  local t = require "triangleBonusTable"

  return t[attackWeapon][defenseWeapon]
end

function SIMULATOR.attack()
end

function SIMULATOR.attack()
end

function SIMULATOR.attack()
end






-- result = SIMULATOR.run(scenario_input)

return SIMULATOR


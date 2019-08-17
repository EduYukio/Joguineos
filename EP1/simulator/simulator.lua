local SIMULATOR = {}

local CALCULATE = require "calculate"

function SIMULATOR.run(scenario_input)
  math.randomseed(scenario_input.seed)

  for _, fighter in pairs(scenario_input.fights) do
    local attacker = scenario_input.units[fighter[1]]
    local defender = scenario_input.units[fighter[2]]

    SIMULATOR.round(attacker, defender, scenario_input.weapons)
  end

  local result = {}
  for name, stats in pairs(scenario_input.units) do
    result[name] = {hp = stats.hp}
  end

  return result
end

function SIMULATOR.round(attacker, defender, weapons)
  SIMULATOR.attack(attacker, defender, weapons)
  SIMULATOR.attack(defender, attacker, weapons)

  if(attacker.hp == 0 or defender.hp == 0) then return end

  local attackerAtkSpd = CALCULATE.atkSpd(attacker, weapons)
  local defenderAtkSpd = CALCULATE.atkSpd(defender, weapons)

  if (attackerAtkSpd - defenderAtkSpd >= 4) then
    SIMULATOR.attack(attacker, defender, weapons)
  elseif (defenderAtkSpd - attackerAtkSpd >= 4) then
    SIMULATOR.attack(defender, attacker, weapons)
  end
end

function SIMULATOR.attack(attacker, defender, weapons)
  if(attacker.hp == 0 or defender.hp == 0) then return end

  local hitChance = CALCULATE.hitChance(attacker, defender, weapons)
  if(math.floor((math.random(100) + math.random(100))/2) <= hitChance) then
    local critical = false
    local critChance = CALCULATE.critChance(attacker, defender, weapons)

    if(math.random(100) <= critChance) then critical = true end

    local damage = CALCULATE.damage(attacker, defender, weapons, critical)
    if (damage > 0)      then defender.hp = defender.hp - damage end
    if (defender.hp < 0) then defender.hp = 0 end
  end
end

return SIMULATOR

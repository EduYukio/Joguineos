local SIMULATOR = {}

local CALCULATE = require "calculate"

function SIMULATOR.run(scenario_input)
  math.randomseed(scenario_input.seed)

  for _, fighters in pairs(scenario_input.fights) do
    local attacker = scenario_input.units[fighters[1]]
    local defender = scenario_input.units[fighters[2]]

    SIMULATOR.round(attacker, defender, scenario_input.weapons)
  end

  local units = {}
  for name, stats in pairs(scenario_input.units) do
    units[name] = {hp = stats.hp}
  end

  return units
end

function SIMULATOR.round(attacker, defender, weapons)
  SIMULATOR.attack(attacker, defender, weapons)
  SIMULATOR.attack(defender, attacker, weapons)

  if(attacker.hp == 0 or defender.hp == 0) then return end

  local attackerAtkSpd = CALCULATE.calculateAtkSpd(attacker, weapons)
  local defenderAtkSpd = CALCULATE.calculateAtkSpd(defender, weapons)

  if (attackerAtkSpd - defenderAtkSpd >= 4) then
    SIMULATOR.attack(attacker, defender, weapons)
  elseif (defenderAtkSpd - attackerAtkSpd >= 4) then
    SIMULATOR.attack(defender, attacker, weapons)
  end
end

function SIMULATOR.attack(attacker, defender, weapons)
  if(attacker.hp == 0 or defender.hp == 0) then return end

  local hitChance = CALCULATE.calculateHitChance(attacker, defender, weapons)

  local randomNumber = math.floor((math.random(100) + math.random(100))/2)
  if(randomNumber <= hitChance) then
    local critChance = CALCULATE.calculateCritChance(attacker, defender, weapons)
    local critical = false

    if(math.random(100) <= critChance) then
      critical = true
    end

    local damage = CALCULATE.calculateDamage(attacker, defender, weapons, critical)

    defender.hp = defender.hp - damage
    if (defender.hp <= 0) then
      defender.hp = 0
    end
  end
end

return SIMULATOR

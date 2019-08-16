
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

-- function SIMULATOR.attack(unit)
function SIMULATOR.attack()
end

function SIMULATOR.calculateTriangleBonus(attackWeapon, defenseWeapon)
  local table = require "triangleBonusTable"

  return table[attackWeapon][defenseWeapon]
end

function SIMULATOR.calculateAttackSpeed(unit)
  return unit.spd - math.max(0, unit.wt - unit.str)
end

function SIMULATOR.calculateHitChance(attacker, defender)
  local attackerWeapon = attacker.weapons[attacker.weapon]
  local defenderWeapon = defender.weapons[attacker.weapon]

  local defenderAttackSpeed = SIMULATOR.calculateAttackSpeed(defender)
  local triangleBonus = SIMULATOR.calculateTriangleBonus(attackerWeapon,
                        defenderWeapon)

  local acc = attackerWeapon.hit + attacker.skl*2 +
              attacker.lck + triangleBonus*10

  local avo = (defenderAttackSpeed*2) + defender.lck

  return math.max(0, math.min(100, acc - avo))
end

-- result = SIMULATOR.run(scenario_input)

return SIMULATOR


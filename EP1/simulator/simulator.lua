
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
  local attackWeapon = attacker.weapons[attacker.weapon]
  local defenseWeapon = defender.weapons[defender.weapon]

  local triangleBonus = SIMULATOR.calculateTriangleBonus(attackWeapon,
                        defenseWeapon)

  local defenderAttackSpeed = SIMULATOR.calculateAttackSpeed(defender)
  local acc = attackWeapon.hit + attacker.skl*2 +
              attacker.lck + triangleBonus*10
  local avo = (defenderAttackSpeed*2) + defender.lck

  return math.max(0, math.min(100, acc - avo))
end

function SIMULATOR.calculateCriticalChance(attacker, defender)
  local attackWeapon = attacker.weapons[attacker.weapon]

  local critRate = attackWeapon.crt + (math.floor(attacker.skl/2))
  local dodge = defender.lck

  return math.max(0, math.min(100, critRate - dodge))
end

function SIMULATOR.calculateDamage(attacker, defender, critical)
  local attackWeapon = attacker.weapons[attacker.weapon]
  local defenseWeapon = defender.weapons[defender.weapon]

  local triangleBonus = SIMULATOR.calculateTriangleBonus(attackWeapon,
                        defenseWeapon)

  local criticalBonus = 1
  if(critical) then
    criticalBonus = 3
  end

  local effBonus = 1
  if(attackWeapon.eff and defender.trait and
     attackWeapon.eff == defender.trait) then
    effBonus = 2
  end

  local power = (attackWeapon.mt + triangleBonus)*effBonus
  if(attackWeapon.kind == "sword" or "axe" or "lance") then
    power = power + attacker.str - defender.def
  else
    power = power + attacker.mag - defender.res
  end

  return power*criticalBonus
end

-- result = SIMULATOR.run(scenario_input)

return SIMULATOR


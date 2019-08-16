local SIMULATOR = {}

function SIMULATOR.run(scenario_input)
  math.randomseed(scenario_input.seed)

  for attacker, defender in pairs(scenario_input.fights) do
    SIMULATOR.round(attacker, defender)
  end

  return scenario_input.output.units
end

function SIMULATOR.round(attacker, defender)
  attacker:attack(defender)
  defender:attack(attacker)

  local attackerAtkSpd = SIMULATOR.calculateAtkSpd(attacker)
  local defenderAtkSpd = SIMULATOR.calculateAtkSpd(defender)

  if (attackerAtkSpd - defenderAtkSpd >= 4) then
    attacker:attack(defender)
  elseif (defenderAtkSpd - attackerAtkSpd >= 4) then
    defender:attack(attacker)
  end
end

function SIMULATOR.attack(attacker, defender)
  local hitChance = SIMULATOR.calculateHitChance(attacker, defender)
  local damage = 0

  if((math.random(100) + math.random(100) / 2) <= hitChance) then
    local critChance = SIMULATOR.calculateCritChance(attacker, defender)
    local critical = false

    if(math.random(100) <= critChance) then
      critical = true
    end

    damage = SIMULATOR.calculateDamage(attacker, defender, critical)
  end

  return damage
end

function SIMULATOR.calculateTriangleBonus(attackWeapon, defenseWeapon)
  local table = require "triangleBonusTable"

  return table[attackWeapon][defenseWeapon]
end

function SIMULATOR.calculateAtkSpd(unit)
  return unit.spd - math.max(0, unit.wt - unit.str)
end

function SIMULATOR.calculateHitChance(attacker, defender)
  local attackWeapon = attacker.weapons[attacker.weapon]
  local defenseWeapon = defender.weapons[defender.weapon]

  local triangleBonus = SIMULATOR.calculateTriangleBonus(attackWeapon,
                        defenseWeapon)

  local defenderAttackSpeed = SIMULATOR.calculateAtkSpd(defender)
  local acc = attackWeapon.hit + attacker.skl*2 +
              attacker.lck + triangleBonus*10
  local avo = (defenderAttackSpeed*2) + defender.lck

  return math.max(0, math.min(100, acc - avo))
end

function SIMULATOR.calculateCritChance(attacker, defender)
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


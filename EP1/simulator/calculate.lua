local CALCULATE = {}

function CALCULATE.atkSpd(unit, weapons)
  return unit.spd - math.max(0, weapons[unit.weapon].wt - unit.str)
end

function CALCULATE.triangleBonus(attackWeapon, defenseWeapon)
  local table = require "triangleBonusTable"

  return table[attackWeapon.kind][defenseWeapon.kind]
end

function CALCULATE.hitChance(attacker, defender, weapons)
  local attackWeapon = weapons[attacker.weapon]
  local defenseWeapon = weapons[defender.weapon]

  local triangleBonus = CALCULATE.triangleBonus(attackWeapon,
                        defenseWeapon)

  local defenderAttackSpeed = CALCULATE.atkSpd(defender, weapons)
  local acc = attackWeapon.hit + attacker.skl*2 +
              attacker.lck + triangleBonus*10
  local avo = (defenderAttackSpeed*2) + defender.lck

  return math.max(0, math.min(100, acc - avo))
end

function CALCULATE.critChance(attacker, defender, weapons)
  local attackWeapon = weapons[attacker.weapon]

  local critRate = attackWeapon.crt + (math.floor(attacker.skl/2))
  local dodge = defender.lck

  return math.max(0, math.min(100, critRate - dodge))
end

function CALCULATE.damage(attacker, defender, weapons, critical)
  local attackWeapon = weapons[attacker.weapon]
  local defenseWeapon = weapons[defender.weapon]

  local triangleBonus = CALCULATE.triangleBonus(attackWeapon,
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
  local physicalWeapons = {
    sword = true,
    axe = true,
    lance = true,
    bow = true
  }
  if(physicalWeapons[attackWeapon.kind] ~= nil ) then
    power = power + attacker.str - defender.def
  else
    power = power + attacker.mag - defender.res
  end

  if(power <= 0) then return 0 end
  return power*criticalBonus
end

return CALCULATE
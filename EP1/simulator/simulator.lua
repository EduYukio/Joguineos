local SIMULATOR = {}

function SIMULATOR.run(scenario_input)
  math.randomseed(scenario_input.seed)
  -- print("\nseed: " .. scenario_input.seed .. "\nrngs: ")
  -- for _=1,10 do
  --   print(math.random(100))
  -- end

  for _, fighters in pairs(scenario_input.fights) do
    local attacker = scenario_input.units[fighters[1]]
    local defender = scenario_input.units[fighters[2]]

    SIMULATOR.round(attacker, defender, scenario_input.weapons)
  end

  local units = {
  }

  for name, stats in pairs(scenario_input.units) do
    -- output.units[name] = scenario_input.units[name].hp
    units[name] = {hp = stats.hp}
  end

  return units
end

function SIMULATOR.round(attacker, defender, weapons)
  SIMULATOR.attack(attacker, defender, weapons)
  SIMULATOR.attack(defender, attacker, weapons)

  if(attacker.hp == 0 or defender.hp == 0) then return end

  local attackerAtkSpd = SIMULATOR.calculateAtkSpd(attacker, weapons)
  local defenderAtkSpd = SIMULATOR.calculateAtkSpd(defender, weapons)

  -- print("\natkspd attack: ".. attackerAtkSpd .. "\natkspd defend: ".. defenderAtkSpd)
  if (attackerAtkSpd - defenderAtkSpd >= 4) then
    SIMULATOR.attack(attacker, defender, weapons)
  elseif (defenderAtkSpd - attackerAtkSpd >= 4) then
    SIMULATOR.attack(defender, attacker, weapons)
  end
end

function SIMULATOR.attack(attacker, defender, weapons)
  -- print("\nattack: " .. attacker.weapon .. " " .. attacker.hp .. " vs " .. defender.weapon .. " "..defender.hp.."\n")
  if(attacker.hp == 0 or defender.hp == 0) then return end

  local hitChance = SIMULATOR.calculateHitChance(attacker, defender, weapons)

  local randomNumber = math.floor((math.random(100) + math.random(100))/2)
  if(randomNumber <= hitChance) then
    local critChance = SIMULATOR.calculateCritChance(attacker, defender, weapons)
    local critical = false

    if(math.random(100) <= critChance) then
      critical = true
    end

    local damage = SIMULATOR.calculateDamage(attacker, defender, weapons, critical)
    -- print("\ndamage: " .. damage .. "\n")

    defender.hp = defender.hp - damage
    if (defender.hp <= 0) then
      defender.hp = 0
    end
  -- else
    -- print("\n" .. attacker.weapon .. " attack " .. " miss")
  end

end

function SIMULATOR.calculateAtkSpd(unit, weapons)
  return unit.spd - math.max(0, weapons[unit.weapon].wt - unit.str)
end

function SIMULATOR.calculateTriangleBonus(attackWeapon, defenseWeapon)
  local table = require "triangleBonusTable"

  -- print("\nattackWeapon.kind: " .. attackWeapon.kind .. "\ndefenseWeapon.kind: " .. defenseWeapon.kind)
  return table[attackWeapon.kind][defenseWeapon.kind]
end

function SIMULATOR.calculateHitChance(attacker, defender, weapons)
  local attackWeapon = weapons[attacker.weapon]
  local defenseWeapon = weapons[defender.weapon]

  local triangleBonus = SIMULATOR.calculateTriangleBonus(attackWeapon,
                        defenseWeapon)

  local defenderAttackSpeed = SIMULATOR.calculateAtkSpd(defender, weapons)
  local acc = attackWeapon.hit + attacker.skl*2 +
              attacker.lck + triangleBonus*10
  local avo = (defenderAttackSpeed*2) + defender.lck

  return math.max(0, math.min(100, acc - avo))
end

function SIMULATOR.calculateCritChance(attacker, defender, weapons)
  local attackWeapon = weapons[attacker.weapon]

  local critRate = attackWeapon.crt + (math.floor(attacker.skl/2))
  local dodge = defender.lck

  return math.max(0, math.min(100, critRate - dodge))
end

function SIMULATOR.calculateDamage(attacker, defender, weapons, critical)
  local attackWeapon = weapons[attacker.weapon]
  local defenseWeapon = weapons[defender.weapon]

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

  -- print("\ncalcDmg:\n mt: " .. attackWeapon.mt .. "\ntriang: " .. triangleBonus ..
    -- "\neffBonus: " .. effBonus .. "\nstr: " .. attacker.str .. "\nmag: ".. attacker.mag.. "\ndef: "..
     -- defender.def .. "\nres: " .. defender.res .. "\ncrit: " .. criticalBonus)

  local power = (attackWeapon.mt + triangleBonus)*effBonus
  if(attackWeapon.kind == "sword" or
     attackWeapon.kind == "axe" or
     attackWeapon.kind == "lance" or
     attackWeapon.kind == "bow") then
    power = power + attacker.str - defender.def
  else
    power = power + attacker.mag - defender.res
  end

  if(power <= 0) then return 0 end
  return power*criticalBonus
end

return SIMULATOR

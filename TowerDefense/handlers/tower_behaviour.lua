
local PALETTE_DB = require 'database.palette'
local PROPERTIES = require 'database.properties'

local TowerBehaviour = require 'common.class' ()

function TowerBehaviour:_init(stage)
  self.stage = stage
  self.util = self.stage.util
  self.dmg_buff_factor = PROPERTIES.buff_factor
end

function TowerBehaviour:farmer_action(tower, dt)
  tower.gold_timer = tower.gold_timer + dt
  if tower.gold_timer > tower.special.gold_making_delay then
    self.util:add_gold(tower.special.gold_to_produce)
    tower.gold_timer = 0
    tower.sfx:play()
    tower.p_system:emit(20)
  end
end

function TowerBehaviour:damage_action(tower, target)
  local damage = tower.damage + tower.damage*tower.damage_buffs*self.dmg_buff_factor

  self.util:apply_damage(target, damage)
end

function TowerBehaviour:slow_action(tower, target) --luacheck: no self
  local speed_after_slow = target.base_speed/tower.special.slow
  if target.speed > speed_after_slow then
    target.speed = speed_after_slow
  end
end

function TowerBehaviour:find_target(tower, index)
  local target
  if tower.damage > 0 or tower.special.slow then
    target = self:find_nearest_unit(tower, self.stage.monsters)
  elseif tower.special.buff then
    target = self:find_nearest_unit(tower, self.stage.towers)
  end

  if target then
    tower.target_array[index] = target
    self:add_laser(tower, target, index)
    if tower.special and tower.special.buff then
      target.damage_buffs = target.damage_buffs + 1
    end
  end
end

function TowerBehaviour:find_nearest_unit(tower, unit_array)
  local min_distance = math.huge
  local nearest_unit = nil

  for unit in pairs(unit_array) do
    local distance = self:distance_to_unit(tower, unit)
    if self:valid_unit(tower, unit) then
      if distance < min_distance then
        min_distance = distance
        nearest_unit = unit
      end
    end
  end

  if min_distance <= tower.range then
    return nearest_unit
  else
    return false
  end
end

function TowerBehaviour:add_laser(tower, target, index)
  local tower_position = self.stage.atlas:get(tower).position
  local target_position = self.stage.atlas:get(target).position

  local color = PALETTE_DB.dark_red
  if tower.special then
    if tower.special.slow then
      color = PALETTE_DB.purple
    elseif tower.special.buff then
      color = PALETTE_DB.green
    end
  end
  self.stage.lasers:add(tower, index, tower_position, target_position, color)
end

function TowerBehaviour:valid_unit(tower, unit)
  if unit.category == "monster" then
    local already_targeted = self:already_targeted(tower, unit)

    if not already_targeted then
      return true
    end
  elseif unit.category == "tower" then
    if not unit.special then
      return true
    end
  end

  return false
end

function TowerBehaviour:already_targeted(tower, unit) --luacheck: no self
  if tower.target_policy == 3 then
    for _, target in ipairs(tower.target_array) do
      if unit == target then
        return true
      end
    end
  end

  return false
end

function TowerBehaviour:distance_to_unit(tower, unit)
  local unit_sprite = self.stage.atlas:get(unit)
  local tower_sprite = self.stage.atlas:get(tower)

  if not tower_sprite or not unit_sprite then return math.huge end
  return (tower_sprite.position - unit_sprite.position):length()
end

function TowerBehaviour:target_is_in_range(tower, target)
  if not target then return false end

  local distance = self:distance_to_unit(tower, target)

  if distance <= tower.range then
    return true
  end

  return false
end

function TowerBehaviour:reset_status(tower, target, index)
  if target then
    self.stage.lasers:remove(tower, index)
    if tower.special and tower.special.slow then
      target.speed = target.base_speed
    end
  end
end



return TowerBehaviour
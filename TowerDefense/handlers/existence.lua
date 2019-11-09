local Vec = require 'common.vec'
local Unit = require 'model.unit'
local SOUNDS = require 'database.sounds'

local Existence = require 'common.class' ()

function Existence:_init(stage)
  self.stage = stage
end

function Existence:create_unit(specname, pos, is_upgrade)
  local unit = Unit(specname)
  local spawn_position = pos
  if not self:can_create_unit(unit, pos) then
    SOUNDS.fail:play()
    return false
  end

  if unit.category == "castle" then
    self.stage.lifebars:add(unit, pos)
    unit.p_system = self.stage.p_systems:add(unit, pos, "white")
  elseif unit.category == "monster" then
    self.stage.monsters[unit] = true

    local special = unit.special
    if special then
      if special.blink_delay then
        unit.blink_timer = 0
        local steps = unit.special.blink_steps
        local dist = (Vec(300, 524) - pos)/steps
        unit.blink_distance = dist
      elseif special.summon_delay then
        unit.summon_timer = 0.8*special.summon_delay
        unit.summons_array = {false, false, false, false}
        unit.initial_position = pos
      elseif special.spawn_position then
        spawn_position = pos + special.spawn_position
      end
    end

    self.stage.lifebars:add(unit, spawn_position)
  elseif unit.category == "tower" then
    self.stage.towers[unit] = true

    if unit.target_policy == 0 then
      unit.target_array = {}
      unit.gold_timer = 0
      unit.sfx = SOUNDS.generate_gold:clone()
      unit.p_system = self.stage.p_systems:add(unit, pos, "yellow")
    elseif unit.target_policy == 1 then
      unit.target_array = {false}
      unit.p_system = self.stage.p_systems:add(unit, pos, "blue")
    elseif unit.target_policy == 3 then
      unit.target_array = {false, false, false}
      unit.p_system = self.stage.p_systems:add(unit, pos, "blue")
    end

    if not is_upgrade then
      SOUNDS.select_menu:play()
      self.stage:add_gold(-unit.cost)
    end
  end

  self.stage.atlas:add(unit, spawn_position, unit:get_appearance())

  return unit
end

function Existence:remove_unit(unit, hit_castle)
  if unit.category == "monster" then
    for tower in pairs(self.stage.towers) do
      for i, target in ipairs(tower.target_array) do
        if unit == target then
          self.stage.lasers:remove(tower, i)
          tower.target_array[i] = false
          break
        end
      end
    end

    if unit.owner then
      unit.owner.summons_array[unit.id] = false
    end
    self.stage.monsters[unit] = nil
    SOUNDS.monster_dying:play()

    if not hit_castle then
      self.stage:add_gold(unit.reward)
    end
  elseif unit.category == "tower" then
    for i, _ in ipairs(unit.target_array) do
      self.stage.lasers:remove(unit, i)
    end
    self.stage.p_systems:remove(unit)
    self.stage.towers[unit] = nil
  elseif unit.category == "castle" then
    self.stage.castle = nil
  end

  self.stage.lifebars:remove(unit)
  self.stage.atlas:remove(unit)
end

function Existence:can_create_unit(unit, pos)
  if unit.category == "tower" then
    if unit.cost > self.stage.gold then
      return false
    end

    local castle_sprite = self.stage.atlas:get(self.stage.castle)
    if castle_sprite.position == pos then
      return false
    end

    for tower in pairs(self.stage.towers) do
      local tower_sprite = self.stage.atlas:get(tower)
      if tower_sprite.position == pos then
        return false
      end
    end
  end

  return true
end

return Existence
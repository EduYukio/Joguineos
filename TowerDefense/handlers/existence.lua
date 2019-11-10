
local Vec = require 'common.vec'
local Unit = require 'model.unit'
local SOUNDS_DB = require 'database.sounds'

local Existence = require 'common.class' ()

function Existence:_init(stage)
  self.stage = stage
  self.lifebars = self.stage.lifebars
  self.towers = self.stage.towers
  self.monsters = self.stage.monsters
  self.p_systems = self.stage.p_systems
  self.atlas = self.stage.atlas
  self.lasers = self.stage.lasers
  self.gold = self.stage.gold
  self.util = self.stage.util
  self.castle_pos = Vec(300, 524)
end

function Existence:can_create_unit(unit, pos)
  if unit.category == "tower" then
    if unit.cost > self.gold then
      return false
    end

    local castle_sprite = self.atlas:get(self.stage.castle)
    if castle_sprite and castle_sprite.position == pos then
      return false
    end

    for tower in pairs(self.towers) do
      local tower_sprite = self.atlas:get(tower)
      if tower_sprite.position == pos then
        return false
      end
    end
  end

  return true
end

function Existence:create_castle(unit, pos)
  unit.p_system = self.p_systems:add(unit, pos, "white")
  self.lifebars:add(unit, pos)
  self.atlas:add(unit, pos, unit:get_appearance())
end

function Existence:create_monster(unit, pos)
  self.monsters[unit] = true
  local spawn_position = pos
  local special = unit.special
  if special then
    if special.blink_delay then
      unit.blink_timer = 0
      local steps = unit.special.blink_steps
      local dist = (self.castle_pos - pos)/steps
      unit.blink_distance = dist
    elseif special.summon_delay then
      unit.summon_timer = special.summon_delay
      unit.summons_array = {false, false, false, false}
      unit.initial_position = pos
    elseif special.spawn_position then
      spawn_position = pos + special.spawn_position
    end
  end

  self.lifebars:add(unit, spawn_position)
  self.atlas:add(unit, spawn_position, unit:get_appearance())
end

function Existence:create_tower(unit, pos, is_upgrading)
  self.towers[unit] = true
  if unit.target_policy == 0 then
    unit.target_array = {}
    unit.gold_timer = 0
    unit.sfx = SOUNDS_DB.generate_gold:clone()
    unit.p_system = self.p_systems:add(unit, pos, "yellow")
  elseif unit.target_policy == 1 then
    unit.target_array = {false}
    unit.p_system = self.p_systems:add(unit, pos, "blue")
  elseif unit.target_policy == 3 then
    unit.target_array = {false, false, false}
    unit.p_system = self.p_systems:add(unit, pos, "blue")
  end

  if not is_upgrading then
    SOUNDS_DB.select_menu:play()
    self.util:add_gold(-unit.cost)
  end

  self.atlas:add(unit, pos, unit:get_appearance())
end

function Existence:create_unit(specname, pos, is_upgrading)
  local unit = Unit(specname)
  if not self:can_create_unit(unit, pos) then
    SOUNDS_DB.fail:play()
    return false
  end

  if unit.category == "castle" then
    self:create_castle(unit, pos)
  elseif unit.category == "monster" then
    self:create_monster(unit, pos)
  elseif unit.category == "tower" then
    self:create_tower(unit, pos, is_upgrading)
  end

  return unit
end

function Existence:remove_monster(unit, hit_castle)
  for tower in pairs(self.towers) do
    for i, target in ipairs(tower.target_array) do
      if unit == target then
        self.lasers:remove(tower, i)
        tower.target_array[i] = false
        break
      end
    end
  end

  if unit.owner then
    unit.owner.summons_array[unit.id] = false
  end

  if not hit_castle then
    self.util:add_gold(unit.reward)
  end

  SOUNDS_DB.monster_dying:play()
  self.monsters[unit] = nil
end

function Existence:remove_tower(unit)
  for i, _ in ipairs(unit.target_array) do
    self.lasers:remove(unit, i)
  end
  self.p_systems:remove(unit)
  self.towers[unit] = nil
end

function Existence:remove_unit(unit, hit_castle)
  if unit.category == "monster" then
    self:remove_monster(unit, hit_castle)
  elseif unit.category == "tower" then
    self:remove_tower(unit)
  elseif unit.category == "castle" then
    self.stage.castle = nil
  end

  self.lifebars:remove(unit)
  self.atlas:remove(unit)
end

return Existence

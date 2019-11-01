
local Wave = require 'model.wave'
local Unit = require 'model.unit'
local Vec = require 'common.vec'
local Cursor = require 'view.cursor'
local SpriteAtlas = require 'view.sprite_atlas'
local BattleField = require 'view.battlefield'
local Lasers = require 'view.lasers'
local Lifebars = require 'view.lifebars'
local Stats = require 'view.stats'
local State = require 'state'

local PlayStageState = require 'common.class' (State)

function PlayStageState:_init(stack)
  self:super(stack)
  self.stage = nil
  self.cursor = nil
  self.atlas = nil
  self.battlefield = nil
  self.units = nil
  self.wave = nil
  self.stats = nil
  self.monsters = nil
  self.towers = nil
  self.lasers = nil
  self.lifebars = nil
end

function PlayStageState:enter(params)
  self.stage = params.stage
  self:_load_view()
  self:_load_units()
end

function PlayStageState:leave()
  self:view('bg'):remove('battlefield')
  self:view('fg'):remove('atlas')
  self:view('fg'):remove('laser')
  self:view('fg'):remove('lifebar')
  self:view('bg'):remove('cursor')
  self:view('hud'):remove('stats')
end

function PlayStageState:_load_view()
  self.battlefield = BattleField()
  self.atlas = SpriteAtlas()
  self.cursor = Cursor(self.battlefield)
  self.lasers = Lasers()
  self.lifebars = Lifebars()
  local _, right, top, _ = self.battlefield.bounds:get()
  self.stats = Stats(Vec(right + 16, top))
  self:view('bg'):add('battlefield', self.battlefield)
  self:view('fg'):add('atlas', self.atlas)
  self:view('fg'):add('laser', self.lasers)
  self:view('fg'):add('lifebar', self.lifebars)
  self:view('bg'):add('cursor', self.cursor)
  self:view('hud'):add('stats', self.stats)
end

function PlayStageState:_load_units()
  local pos = self.battlefield:tile_to_screen(0, 7)
  self.units = {}
  self.castle = self:_create_unit_at('castle', pos)
  self.wave = Wave(self.stage.waves[1])
  self.wave:start()
  self.monsters = {}
  self.towers = {}
end

function PlayStageState:check_if_can_create_unit(unit, pos)
  if unit.category == "tower" then
    local castle_sprite = self.atlas:get(self.castle)
    if castle_sprite.position == pos then
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

function PlayStageState:check_if_monster_hit_castle(monster)
  local monster_sprite = self.atlas:get(monster)
  local castle_sprite = self.atlas:get(self.castle)

  local monster_position = self.battlefield:round_to_tile(monster_sprite.position)
  if monster_position == castle_sprite.position then
    return true
  end

  return false
end

function PlayStageState:_create_unit_at(specname, pos)
  local unit = Unit(specname)
  if not self:check_if_can_create_unit(unit, pos) then
    return false
  end

  self.atlas:add(unit, pos, unit:get_appearance())
  self.lifebars:add(unit, pos)

  return unit
end

function PlayStageState:remove_unit(unit)
  if unit.category == "monster" then
    self.monsters[unit] = nil
  elseif unit.category == "castle" then
    --TODO: fazer um menu de game over
    self:pop()
  end
  self.lifebars:remove(unit)
  self.atlas:remove(unit)
end

function PlayStageState:on_mousepressed(_, _, button)
  if button == 1 then
    local tower = self:_create_unit_at('warrior', Vec(self.cursor:get_position()))

    if tower then
      self.towers[tower] = true
      tower.target = nil
    end
  end
end

function PlayStageState:distance_to_monster(tower, monster)
  if not tower or not monster then return nil end
  local monster_sprite = self.atlas:get(monster)
  local tower_sprite = self.atlas:get(tower)

  return (tower_sprite.position - monster_sprite.position):length()
end

function PlayStageState:find_nearest_monster(tower, monsters)
  local min_distance = math.huge
  local nearest_monster = nil

  for monster in pairs(monsters) do
    local distance = self:distance_to_monster(tower, monster)
    if distance < min_distance then
      min_distance = distance
      nearest_monster = monster
    end
  end

  if min_distance < tower.range then
    return nearest_monster
  else
    return nil
  end
end

function PlayStageState:find_target_and_add_laser(tower)
  tower.target = self:find_nearest_monster(tower, self.monsters)
  if tower.target then
    local tower_position = self.atlas:get(tower).position
    local monster_position = self.atlas:get(tower.target).position
    self.lasers:add(tower, tower_position, monster_position)
  end
end

function PlayStageState:take_damage(who, damage)
  local unit = who
  unit.hp = unit.hp - damage

  local hp_percentage = unit.hp / unit.max_hp
  self.lifebars:x_scale(unit, hp_percentage)

  if unit.hp <= 0 then
    self:remove_unit(unit)
  end
end

function PlayStageState:tower_attack(tower)
  local monster = tower.target
  monster.hp = monster.hp - tower.damage
  local hp_percentage = monster.hp / monster.max_hp
  self.lifebars:x_scale(monster, hp_percentage)

  if monster.hp <= 0 then
    self:remove_unit(monster)
  end
end

function PlayStageState:check_if_monster_died(monster, tower)
  if self.monsters[monster] == nil then
    self.lasers:remove(tower)
    tower.target = nil
  end
end

function PlayStageState:update(dt)
  self.wave:update(dt)
  local pending = self.wave:poll()

  -- spawn monsters
  while pending > 0 do
    local rng = math.random(-1, 1)
    local x, y = 7 * rng, -7
    local pos = self.battlefield:tile_to_screen(x, y)
    local monster = self:_create_unit_at('green_slime', pos)
    monster.direction = rng
    self.monsters[monster] = true
    pending = pending - 1
  end

  -- position monsters
  for monster in pairs(self.monsters) do
    local sprite_instance = self.atlas:get(monster)
    local speed = 100 * dt
    local x_dir = -7.5 * monster.direction
    local y_dir = 15
    local direction = Vec(x_dir, y_dir):normalized()
    local delta_s = direction * speed

    sprite_instance.position:add(delta_s)
    self.lifebars:add_position(monster, delta_s)

    if self:check_if_monster_hit_castle(monster) then
      self:take_damage(self.castle, 1)
      self:remove_unit(monster)
    end
  end

  -- towers attack management
  for tower in pairs(self.towers) do
    if tower.target then
      self:check_if_monster_died(tower.target, tower)
    end

    if tower.target then
      local distance = self:distance_to_monster(tower, tower.target)

      if distance > tower.range then
        self.lasers:remove(tower)
        self:find_target_and_add_laser(tower)
      else
        self:take_damage(tower.target, tower.damage)
      end
    else
      self:find_target_and_add_laser(tower)
    end
  end
end

return PlayStageState


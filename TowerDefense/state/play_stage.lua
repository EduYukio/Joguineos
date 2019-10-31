
local Wave = require 'model.wave'
local Unit = require 'model.unit'
local Vec = require 'common.vec'
local Cursor = require 'view.cursor'
local SpriteAtlas = require 'view.sprite_atlas'
local BattleField = require 'view.battlefield'
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
end

function PlayStageState:enter(params)
  self.stage = params.stage
  self:_load_view()
  self:_load_units()
end

function PlayStageState:leave()
  self:view('bg'):remove('battlefield')
  self:view('fg'):remove('atlas')
  self:view('bg'):remove('cursor')
  self:view('hud'):remove('stats')
end

function PlayStageState:_load_view()
  self.battlefield = BattleField()
  self.atlas = SpriteAtlas()
  self.cursor = Cursor(self.battlefield)
  local _, right, top, _ = self.battlefield.bounds:get()
  self.stats = Stats(Vec(right + 16, top))
  self:view('bg'):add('battlefield', self.battlefield)
  self:view('fg'):add('atlas', self.atlas)
  self:view('bg'):add('cursor', self.cursor)
  self:view('hud'):add('stats', self.stats)
end

function PlayStageState:_load_units()
  local pos = self.battlefield:tile_to_screen(-6, 6)
  self.units = {}
  self:_create_unit_at('capital', pos)
  self.wave = Wave(self.stage.waves[1])
  self.wave:start()
  self.monsters = {}
  self.towers = {}
end

local function create_life_bar(unit, pos, stage)
  local lifeBarPos = pos:clone()
  lifeBarPos:add(Vec(0, -22))
  unit.lifebar = stage.atlas:add({}, lifeBarPos, 'lifebar')
end

function PlayStageState:_create_unit_at(specname, pos)
  local unit = Unit(specname)
  self.atlas:add(unit, pos, unit:get_appearance())

  create_life_bar(unit, pos, self)

  return unit
end

function PlayStageState:on_mousepressed(_, _, button)
  if button == 1 then
    local tower = self:_create_unit_at('warrior', Vec(self.cursor:get_position()))
    self.towers[tower] = true
    tower.target = nil
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

function PlayStageState:tower_attack(tower, dt)
  local sprite_instance = self.atlas:get(tower.target)
  sprite_instance.position:add(Vec(-1, 1) * 20 * dt)
  tower.target.lifebar.position:add(Vec(-1, 1) * 20 * dt)
end

function PlayStageState:update(dt)
  self.wave:update(dt)
  local pending = self.wave:poll()
  local rand = love.math.random

  -- spawn monsters
  while pending > 0 do
    local x, y = rand(5, 7), -rand(5, 7)
    local pos = self.battlefield:tile_to_screen(x, y)
    local monster = self:_create_unit_at('green_slime', pos)
    self.monsters[monster] = true
    pending = pending - 1
  end

  -- position monsters
  for monster in pairs(self.monsters) do
    local sprite_instance = self.atlas:get(monster)
    sprite_instance.position:add(Vec(-1, 1) * 10 * dt)
    monster.lifebar.position:add(Vec(-1, 1) * 10 * dt)
  end

  -- towers attack management
  for tower in pairs(self.towers) do
    if tower.target then
      --verifica se ta na range e tals
      local distance = self:distance_to_monster(tower, tower.target)
      if distance > tower.range then
        tower.target = self:find_nearest_monster(tower, self.monsters)
      else
        self:tower_attack(tower, dt)
      end
    else
      --procura o target mais proximo
      tower.target = self:find_nearest_monster(tower, self.monsters)
    end
  end
end

return PlayStageState


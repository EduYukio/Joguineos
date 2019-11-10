
local Vec = require 'common.vec'
local SOUNDS_DB = require 'database.sounds'

local MonsterBehaviour = require 'common.class' ()

function MonsterBehaviour:_init(stage)
  self.stage = stage
  self.existence = self.stage.existence
  self.battlefield = self.stage.battlefield
  self.atlas = self.stage.atlas
  self.lifebars = self.stage.lifebars
  self.monsters = self.stage.monsters
  self.util = self.stage.util
end

function MonsterBehaviour:blinker_action(blinker, dt)
  blinker.blink_timer = blinker.blink_timer + dt
  if blinker.blink_timer > blinker.special.blink_delay then
    blinker.blink_timer = 0

    local sprite_instance = self.atlas:get(blinker)
    local delta_s = blinker.blink_distance

    sprite_instance.position:add(delta_s)
    self.lifebars:add_position(blinker, delta_s)
  end
end

function MonsterBehaviour:count_live_summons(summoner) --luacheck: no self
  local summon_count = 0
  for i = 1, 4 do
    if summoner.summons_array[i] then
      summon_count = summon_count + 1
    end
  end
  return summon_count
end

function MonsterBehaviour:summon_monster(summoner, sprite_instance, summons, index)
  local pos = sprite_instance.position
  local summoned_monster = self.existence:create_unit(summons[index], pos)
  summoner.summons_array[index] = summoned_monster

  summoned_monster.owner = summoner
  summoned_monster.id = index

  summoned_monster.x_dir = 0
  if summoner.initial_position.x < 300 then
    summoned_monster.x_dir = -1
  elseif summoner.initial_position.x > 300 then
    summoned_monster.x_dir = 1
  end
end

function MonsterBehaviour:summoner_action(summoner, dt)
  local summon_count = self:count_live_summons(summoner)

  if summon_count < 4 then
    summoner.summon_timer = summoner.summon_timer + dt
  else
    summoner.summon_timer = 0
  end

  if summoner.summon_timer > summoner.special.summon_delay then
    local sprite_instance = self.atlas:get(summoner)
    local summons = summoner.special.summons

    for i = 1, 4 do
      if not summoner.summons_array[i] then
        self:summon_monster(summoner, sprite_instance, summons, i)
      end
    end
  end
end

function MonsterBehaviour:walk(monster, dt)
  local sprite_instance = self.atlas:get(monster)
  local speed = monster.speed * dt
  local x_dir = -7.5 * monster.x_dir
  local y_dir = 15
  local direction = Vec(x_dir, y_dir):normalized()
  local delta_s = direction * speed

  sprite_instance.position:add(delta_s)
  self.lifebars:add_position(monster, delta_s)
end

function MonsterBehaviour:hit_castle(monster)
  local monster_sprite = self.atlas:get(monster)

  local monster_position = self.battlefield:round_to_tile(monster_sprite.position)
  if monster_position == self.stage.castle_pos then
    SOUNDS_DB.castle_take_hit:play()
    return true
  end

  return false
end

function MonsterBehaviour:manage_monsters_actions(dt)
  for monster in pairs(self.monsters) do
    if monster.blink_timer then
      self:blinker_action(monster, dt)
    else
      self:walk(monster, dt)
    end

    if monster.summon_timer then
      self:summoner_action(monster, dt)
    end

    if self:hit_castle(monster) then
      self.util:apply_damage(self.stage.castle, 1)
      self.existence:remove_unit(monster, true)
      if self.stage.game_over then return end
    end
  end
end

return MonsterBehaviour

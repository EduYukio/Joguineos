local Vec = require 'common.vec'
local Existence = require 'handlers.existence'
local SOUNDS = require 'database.sounds'

local MonsterBehaviour = require 'common.class' ()

function MonsterBehaviour:_init(stage)
  self.stage = stage
  self.existence = Existence(stage)
end

function MonsterBehaviour:blinker_action(monster, dt)
  monster.blink_timer = monster.blink_timer + dt
  if monster.blink_timer > monster.special.blink_delay then
    monster.blink_timer = 0

    local sprite_instance = self.stage.atlas:get(monster)
    local delta_s = monster.blink_distance

    sprite_instance.position:add(delta_s)
    self.stage.lifebars:add_position(monster, delta_s)
  end
end

function MonsterBehaviour:summoner_action(monster, dt)
  local summon_count = 0
  for i = 1, 4 do
    if monster.summons_array[i] then
      summon_count = summon_count + 1
    end
  end

  if summon_count < 4 then
    monster.summon_timer = monster.summon_timer + dt
  else
    monster.summon_timer = 0
  end

  if monster.summon_timer > monster.special.summon_delay then
    local sprite_instance = self.stage.atlas:get(monster)
    local summons = monster.special.summons

    for i = 1, 4 do
      if not monster.summons_array[i] then
        local pos = sprite_instance.position
        local summoned_monster = self.existence:create_unit(summons[i], pos)
        monster.summons_array[i] = summoned_monster

        summoned_monster.owner = monster
        summoned_monster.id = i

        summoned_monster.direction = 0
        if monster.initial_position.x < 300 then
          summoned_monster.direction = -1
        elseif monster.initial_position.x > 300 then
          summoned_monster.direction = 1
        end
      end
    end
  end
end

function MonsterBehaviour:walk(monster, dt)
  local sprite_instance = self.stage.atlas:get(monster)
  local speed = monster.speed * dt
  local x_dir = -7.5 * monster.direction
  local y_dir = 15
  local direction = Vec(x_dir, y_dir):normalized()
  local delta_s = direction * speed

  sprite_instance.position:add(delta_s)
  self.stage.lifebars:add_position(monster, delta_s)
end

function MonsterBehaviour:hit_castle(monster)
  local monster_sprite = self.stage.atlas:get(monster)
  local castle_sprite = self.stage.atlas:get(self.stage.castle)

  local monster_position = self.stage.battlefield:round_to_tile(monster_sprite.position)
  if monster_position == castle_sprite.position then
    SOUNDS.castle_take_hit:play()
    return true
  end

  return false
end

return MonsterBehaviour


local Wave = require 'model.wave'

local Spawn = require 'common.class' ()

function Spawn:_init(stage)
  self.stage = stage
  self.existence = self.stage.existence

  self.monsters = self.stage.monsters
  self.stats = self.stage.stats
  self.messages = self.stage.messages
  self.level = self.stage.stage
  self.battlefield = self.stage.battlefield

  self.x_spawn_tiles = 7
  self.y_spawn_tiles = -7
  self.last_spawn_direction = 1
  self.wave_index = nil
  self.current_wave = 1
  self.wave = Wave(self.level.waves[self.current_wave])
  self.wave:start()
end

function Spawn:next_monster_from_wave(pos)
  local monster

  for i, name in ipairs(self.wave.order) do
    local remaining = self.wave.quantity[i]

    if remaining > 0 then
      monster = self.existence:create_unit(name, pos)
      self.wave.quantity[i] = self.wave.quantity[i] - 1
      self.wave.delay = self.wave.cooldown[i]
      break
    elseif self.wave.delay < self.wave.default_delay then
      --To avoid spawning a different monster immediately after a spawn burst
      self.wave.delay = self.wave.default_delay
    end
  end

  return monster
end

function Spawn:generate_valid_x_dir()
  local direction = math.random(-1, 1)
  while direction == self.last_spawn_direction do
    direction = math.random(-1, 1)
  end

  self.last_spawn_direction = direction
  return direction
end

function Spawn:no_monsters_on_the_field()
  return next(self.monsters) == nil
end

function Spawn:select_next_wave()
  self.current_wave = self.current_wave + 1
  self.wave_index = self.level.waves[self.current_wave]
  if self.wave_index then
    self.stats.current_wave = self.current_wave
    self.stage.must_spawn_new_wave = true
    self.wave = Wave(self.wave_index)
    self.wave.delay = 0

    return true
  end

  return false
end

function Spawn:new_wave()
  self.stage.must_spawn_new_wave = false
  self.messages:clear()
  self.wave:start()
  self.wave.delay = self.wave.default_delay
end

function Spawn:manage_waves(dt)
  self.wave:update(dt)
  local pending = self.wave:poll()
  while pending > 0 do
    local x_dir = self:generate_valid_x_dir()
    local x_tiles = self.x_spawn_tiles * x_dir
    local pos = self.battlefield:tile_to_screen(x_tiles, self.y_spawn_tiles)

    local new_monster = self:next_monster_from_wave(pos)
    if not new_monster then
      if self:no_monsters_on_the_field() then
        if not self:select_next_wave() then
          self.stage.player_won = true
        end
      end
      break
    else
      new_monster.direction = x_dir
      pending = pending - 1
    end
  end
end

return Spawn
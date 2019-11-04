
local PALETTE_DB = require 'database.palette'

local Wave = require 'model.wave'
local Unit = require 'model.unit'
local Vec = require 'common.vec'
local Cursor = require 'view.cursor'
local SpriteAtlas = require 'view.sprite_atlas'
local BattleField = require 'view.battlefield'
local Lasers = require 'view.lasers'
local Lifebars = require 'view.lifebars'
local Messages = require 'view.messages'
local UI_Select = require 'view.ui_select'
local MonsterRoutes = require 'view.monster_routes'
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
  self.messages = nil
  self.ui_select = nil
end

function PlayStageState:enter(params)
  self.stage = params.stage
  self:_load_view()
  self:_load_units()
end

function PlayStageState:leave()
  self:view('bg'):remove('battlefield')
  self:view('fg'):remove('atlas')
  self:view('fg'):remove('lasers')
  self:view('bg'):remove('cursor')
  self:view('bg'):remove('monster_routes')
  self:view('hud'):remove('lifebars')
  self:view('hud'):remove('stats')
  self:view('hud'):remove('ui_select')
  self:view('hud'):remove('messages')
end

function PlayStageState:_load_view()
  self.battlefield = BattleField()
  self.atlas = SpriteAtlas()
  self.cursor = Cursor(self.battlefield)
  self.lasers = Lasers()
  self.lifebars = Lifebars()
  self.messages = Messages()
  self.monster_routes = MonsterRoutes()
  local _, right, top, _ = self.battlefield.bounds:get()
  self.stats = Stats(Vec(right + 32, top))
  self.ui_select = UI_Select(Vec(right + 32, top + 57))
  self:add_ui_select_sprites()
  self:view('bg'):add('battlefield', self.battlefield)
  self:view('fg'):add('atlas', self.atlas)
  self:view('fg'):add('lasers', self.lasers)
  self:view('bg'):add('cursor', self.cursor)
  self:view('bg'):add('monster_routes', self.monster_routes)
  self:view('hud'):add('lifebars', self.lifebars)
  self:view('hud'):add('stats', self.stats)
  self:view('hud'):add('ui_select', self.ui_select)
  self:view('hud'):add('messages', self.messages)
end

function PlayStageState:_load_units()
  self.units = {}
  self.castle_pos = self.battlefield:tile_to_screen(0, 7)
  self.castle = self:_create_unit_at('castle', self.castle_pos)
  self.current_wave = 1
  self.wave = Wave(self.stage.waves[self.current_wave])
  self.wave:start()
  self.monsters = {}
  self.towers = {}

  self.waiting_time = 0
  self.dmg_buff = 0
  self.selected_tower = 'archer1'
  self.cursor.selected_tower_appearance = self.selected_tower
end

function PlayStageState:add_ui_select_sprites()
  for _,v in pairs(self.ui_select.sprites) do
    self.atlas:add(v.name, v.pos, v.appearance)
  end
end

function PlayStageState:upgrade_unit(appearance)
  if appearance == "castle2" then
    self:remove_unit(self.castle)
    self.castle = self:_create_unit_at('castle2', self.castle_pos)
    return
  end

  if appearance == "archer2" then
    self.ui_select.sprites[1].appearance = appearance
    self:upgrade_towers("Archer", appearance)
  elseif appearance == "knight2" then
    self.ui_select.sprites[2].appearance = appearance
    self:upgrade_towers("Knight", appearance)
  elseif appearance == "mage2" then
    self.ui_select.sprites[3].appearance = appearance
    self:upgrade_towers("Mage", appearance)
  end

  self:add_ui_select_sprites()
  self:upgrade_selected_tower(appearance)
end

function PlayStageState:upgrade_towers(tower_name, appearance)
  for tower in pairs(self.towers) do
    if tower.name == tower_name then
      local pos = self.atlas:get(tower).position
      self:remove_unit(tower)
      local new_tower = self:_create_unit_at(appearance, pos)
      self.towers[new_tower] = true
    end
  end
end

function PlayStageState:upgrade_selected_tower(appearance)
  local curr = self.selected_tower
  if appearance == "archer2" and curr == "archer1" then
    self.selected_tower = "archer2"
  elseif appearance == "knight2" and curr == "knight1" then
    self.selected_tower = "knight2"
  elseif appearance == "mage2" and curr == "mage1" then
    self.selected_tower = "mage2"
  end
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

  if unit.category ~= "tower" then
    self.lifebars:add(unit, pos)
  end
  self.atlas:add(unit, pos, unit:get_appearance())

  return unit
end

function PlayStageState:remove_unit(unit)
  if unit.category == "monster" then
    self.monsters[unit] = nil
  elseif unit.category == "tower" then
    self.lasers:remove(unit)
    self.towers[unit] = nil
  elseif unit.category == "castle" then
    self.castle = nil
  end

  self.lifebars:remove(unit)
  self.atlas:remove(unit)
end

function PlayStageState:take_damage(who, damage)
  local unit = who
  unit.hp = unit.hp - damage

  local hp_percentage = unit.hp / unit.max_hp
  self.lifebars:x_scale(unit, hp_percentage)

  if unit.hp <= 0 then
    if unit.category == "castle" then
      self.game_over = true
    end
    self:remove_unit(unit)
  end
end

function PlayStageState:tower_do_action(tower)
  local target = tower.target
  local special = tower.special
  if not special then
    local damage = tower.damage + tower.damage*tower.damage_buffs*self.dmg_buff

    self:take_damage(target, damage)
  else
    if special.slow then
      local speed_after_slow = target.base_speed/special.slow
      if target.speed > speed_after_slow then
        tower.target.speed = speed_after_slow
      end
    -- elseif special.farm then
      -- make money
    end
  end

end

function PlayStageState:on_mousepressed(_, _, button)
  if button == 1 then
    local mouse_pos = Vec(love.mouse.getPosition())
    if self.battlefield.bounds:is_inside(mouse_pos) then
      local tower = self:_create_unit_at(self.selected_tower, Vec(self.cursor:get_position()))
      if tower then
        self.towers[tower] = true
      end
    else
      for i,v in ipairs(self.ui_select.boxes) do
        if v:is_inside(mouse_pos) then
          local category = self.ui_select.sprites[i].category
          local appearance = self.ui_select.sprites[i].appearance
          if category == "tower" then
            self.selected_tower = appearance
            self.ui_select.selected_box = self.ui_select.boxes[i]
            self.cursor.selected_tower_appearance = self.selected_tower
          elseif category == "upgrade" then
            self:upgrade_unit(appearance)
          end
          break
        end
      end
    end
  end
end

function PlayStageState:distance_to_unit(tower, unit)
  if not tower or not unit then return nil end
  local unit_sprite = self.atlas:get(unit)
  local tower_sprite = self.atlas:get(tower)

  return (tower_sprite.position - unit_sprite.position):length()
end

function PlayStageState:find_nearest_unit(category, tower)
  local min_distance = math.huge
  local nearest_unit = nil

  local unit_array
  if category == "monster" then
    unit_array = self.monsters
  elseif category == "tower" then
    unit_array = self.towers
  end

  for unit in pairs(unit_array) do
    local distance = self:distance_to_unit(tower, unit)
    if distance < min_distance and not unit.special then
      min_distance = distance
      nearest_unit = unit
    end
  end

  if min_distance < tower.range then
    return nearest_unit
  else
    return nil
  end
end

function PlayStageState:find_target_and_add_laser(tower)
  if tower.damage > 0 or tower.special.slow then
    tower.target = self:find_nearest_unit("monster", tower)
  elseif tower.special.buff then
    tower.target = self:find_nearest_unit("tower", tower)
  end

  if tower.target then
    local tower_position = self.atlas:get(tower).position
    local target_position = self.atlas:get(tower.target).position

    local color = PALETTE_DB.red
    if tower.special then
      if tower.special.slow then
        color = PALETTE_DB.purple
      elseif tower.special.buff then
        color = PALETTE_DB.green
        tower.target.damage_buffs = tower.target.damage_buffs + 1
        self.dmg_buff = tower.special.buff
      end
    end
    self.lasers:add(tower, tower_position, target_position, color)
  end
end

function PlayStageState:check_if_target_died(tower)
  local target = tower.target
  if target.category == "monster" then
    if self.monsters[target] ~= nil then
      return
    end
  elseif target.category == "tower" then
    if self.towers[target] ~= nil then
      return
    end
  end

  self.lasers:remove(tower)
  tower.target = nil
end

function PlayStageState:spawn_monsters(dt)
  if self.must_spawn_new_wave then
    self.waiting_time = self.waiting_time + dt
    if self.waiting_time < 1 then
      self.messages:write("Next wave in 3...", Vec(190, 150))
    elseif self.waiting_time < 2 then
      self.messages:write("Next wave in 2...", Vec(190, 150))
    elseif self.waiting_time < 3 then
      self.messages:write("Next wave in 1...", Vec(190, 150))
    else
      self.must_spawn_new_wave = false
      self.waiting_time = 0
      self.messages:clear()
      self.wave:start()
      self.wave.delay = self.wave.default_delay
    end
  elseif self.player_won then
    self.waiting_time = self.waiting_time + dt
    if self.waiting_time < 4 then
      self.messages:write("You Win!", Vec(250, 150))
    else
      self.player_won = false
      self.waiting_time = 0
      self:pop()
      return
    end
  end

  if self.waiting_time ~= 0 then return end

  self.wave:update(dt)
  local pending = self.wave:poll()

  while pending > 0 do
    local spawn_location = math.random(-1, 1)
    local x, y = 7 * spawn_location, -7
    local pos = self.battlefield:tile_to_screen(x, y)

    local monster = nil
    for i, name in ipairs(self.wave.order) do
      local quantity = self.wave.quantity[i]
      if quantity > 0 then
        monster = self:_create_unit_at(name, pos)
        self.wave.quantity[i] = self.wave.quantity[i] - 1
        break
      end
    end

    if not monster then
      -- check if there are monsters on the field
      if next(self.monsters) == nil then
        self.current_wave = self.current_wave + 1
        self.wave_index = self.stage.waves[self.current_wave]

        if self.wave_index then
          self.must_spawn_new_wave = true
          self.wave = Wave(self.wave_index)
          self.wave.delay = 0
        else
          self.player_won = true
        end
      end
      break
    else
      monster.direction = spawn_location
      self.monsters[monster] = true
      pending = pending - 1
    end
  end
end

function PlayStageState:position_monsters(dt)
  for monster in pairs(self.monsters) do
    local sprite_instance = self.atlas:get(monster)
    local speed = monster.speed * dt
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
end

function PlayStageState:manage_tower_attack()
  for tower in pairs(self.towers) do
    if tower.target then
      self:check_if_target_died(tower)
    end

    if tower.target then
      local distance = self:distance_to_unit(tower, tower.target)

      if distance > tower.range then
        tower.target.speed = tower.target.base_speed
        self.lasers:remove(tower)
        self:find_target_and_add_laser(tower)
      else
        self:tower_do_action(tower)
      end
    else
      self:find_target_and_add_laser(tower)
    end
  end
end

function PlayStageState:update(dt)
  if self.game_over then
    self.waiting_time = self.waiting_time + dt
    if self.waiting_time < 3 then
      self.messages:write("Game Over :(", Vec(230, 150))
    else
      self.game_over = false
      self.waiting_time = 0
      self:pop()
      return
    end
  else
    self:spawn_monsters(dt)
    self:position_monsters(dt)
    self:manage_tower_attack()
  end
end

return PlayStageState


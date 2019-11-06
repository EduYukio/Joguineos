
local PALETTE_DB = require 'database.palette'
local properties = require 'database.properties'

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
local UI_Info = require 'view.ui_info'
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
  self.ui_info = nil
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
  self:view('hud'):remove('ui_info')
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
  self.gold = self.stage.initial_gold
  self.stats.gold = self.gold

  self.ui_info = UI_Info(Vec(right + 250, top + 10))
  self.ui_select = UI_Select(Vec(right + 32, top + 57))
  self.ui_select.gold = self.gold
  self:add_ui_select_sprites()

  local wave_count = 0
  for i, _ in ipairs(self.stage.waves) do
    wave_count = wave_count + 1
  end
  self.stats.number_of_waves = wave_count
  self.stats.current_wave = 1

  self:view('bg'):add('battlefield', self.battlefield)
  self:view('fg'):add('atlas', self.atlas)
  self:view('fg'):add('lasers', self.lasers)
  self:view('bg'):add('cursor', self.cursor)
  self:view('bg'):add('monster_routes', self.monster_routes)
  self:view('hud'):add('lifebars', self.lifebars)
  self:view('hud'):add('stats', self.stats)
  self:view('hud'):add('ui_select', self.ui_select)
  self:view('hud'):add('ui_info', self.ui_info)
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
  self.last_spawn_location = 1
  self.dmg_buff = 0
  self.selected_tower = nil
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
  local position_array = {}
  for tower in pairs(self.towers) do
    if tower.name == tower_name then
      local pos = self.atlas:get(tower).position
      table.insert(position_array, pos)
      self:remove_unit(tower)
    end
  end

  for _, pos in ipairs(position_array) do
    local new_tower = self:_create_unit_at(appearance, pos, true)
    self.towers[new_tower] = true
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

function PlayStageState:add_gold(value)
  self.gold = self.gold + value
  self.stats.gold = self.gold
  self.ui_select.gold = self.gold
  --partículas
end

function PlayStageState:check_if_can_create_unit(unit, pos)
  if unit.category == "tower" then
    if unit.cost > self.gold then
      return false
    end

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

function PlayStageState:_create_unit_at(specname, pos, is_upgrade)
  local unit = Unit(specname)
  local spawn_position = pos
  if not self:check_if_can_create_unit(unit, pos) then
    --toca audio de failed tipo PÉÉ ou Ã-Ã
    return false
  end

  if unit.category == "castle" then
    self.lifebars:add(unit, pos)
  elseif unit.category == "monster" then
    self.monsters[unit] = true

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

    self.lifebars:add(unit, spawn_position)
  elseif unit.category == "tower" then
    self.towers[unit] = true

    if unit.target_policy == 0 then
      unit.target_array = {}
      unit.gold_timer = 0
    elseif unit.target_policy == 1 then
      unit.target_array = {false}
    elseif unit.target_policy == 3 then
      unit.target_array = {false, false, false}
    end

    if not is_upgrade then
      self:add_gold(-unit.cost)
      if self.gold < properties.cost[unit.name] then
        self:select_tower(nil)
      end
    end
  end

  self.atlas:add(unit, spawn_position, unit:get_appearance())

  return unit
end

function PlayStageState:remove_unit(unit, hit_castle)
  if unit.category == "monster" then
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
    self.monsters[unit] = nil

    if not hit_castle then
      self:add_gold(unit.reward)
    end
  elseif unit.category == "tower" then
    for i, target in ipairs(unit.target_array) do
      self.lasers:remove(unit, i)
    end
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

function PlayStageState:tower_do_action(tower, target)
  local special = tower.special
  if not special then
    local damage = tower.damage + tower.damage*tower.damage_buffs*self.dmg_buff

    self:take_damage(target, damage)
  elseif special.slow then
    local speed_after_slow = target.base_speed/special.slow
    if target.speed > speed_after_slow then
      target.speed = speed_after_slow
    end
  end
end


function PlayStageState:select_tower(appearance, index)
  self.selected_tower = appearance
  self.cursor.selected_tower_appearance = self.selected_tower
  if index then
    self.ui_select.selected_box = self.ui_select.boxes[index]
  else
    self.ui_select.selected_box = nil
  end
end

function PlayStageState:on_mousepressed(_, _, button)
  if button == 1 and not self.game_over then
    local mouse_pos = Vec(love.mouse.getPosition())
    if self.battlefield.bounds:is_inside(mouse_pos) and self.selected_tower then
      self:_create_unit_at(self.selected_tower, Vec(self.cursor:get_position()))
    else
      for i, box in ipairs(self.ui_select.boxes) do
        if box:is_inside(mouse_pos) then
          local spr = self.ui_select.sprites[i]
          if self.gold < properties.cost[spr.name] then --luacheck: ignore
            --toca audio de fail
          else
            if spr.category == "tower" then
              self:select_tower(spr.appearance, i)
            elseif spr.category == "upgrade" and spr.available then
              self:upgrade_unit(spr.appearance)
              self:add_gold(-properties.cost[spr.name])
              spr.available = false
            end
          end
          break
        end
      end
    end
  end
end

function PlayStageState:distance_to_unit(tower, unit)
  local unit_sprite = self.atlas:get(unit)
  local tower_sprite = self.atlas:get(tower)

  if not tower_sprite or not unit_sprite then return math.huge end
  return (tower_sprite.position - unit_sprite.position):length()
end

function PlayStageState:find_nearest_unit(category, tower)
  local min_distance = math.huge
  local nearest_unit = nil
  local is_special_tower

  local unit_array
  if category == "monster" then
    unit_array = self.monsters
  elseif category == "tower" then
    unit_array = self.towers
  end

  for unit in pairs(unit_array) do
    local already_targeted = false
    if tower.target_policy == 3 then
      for _, target in ipairs(tower.target_array) do
        if unit == target then
          already_targeted = true
          break
        end
      end
    end

    local distance = self:distance_to_unit(tower, unit)

    if category == "tower" and unit.special then
      is_special_tower = true
    else
      is_special_tower = false
    end

    if distance < min_distance and not is_special_tower and not already_targeted then
      min_distance = distance
      nearest_unit = unit
    end
  end

  if min_distance < tower.range then
    return nearest_unit
  else
    return false
  end
end

function PlayStageState:find_target_and_add_laser(tower, index)
  if tower.damage > 0 or tower.special.slow then
    tower.target_array[index] = self:find_nearest_unit("monster", tower)
  elseif tower.special.buff then
    tower.target_array[index] = self:find_nearest_unit("tower", tower)
  end
  local target = tower.target_array[index]

  if target then
    local tower_position = self.atlas:get(tower).position
    local target_position = self.atlas:get(target).position

    local color = PALETTE_DB.red
    if tower.special then
      if tower.special.slow then
        color = PALETTE_DB.purple
      elseif tower.special.buff then
        color = PALETTE_DB.green
        target.damage_buffs = target.damage_buffs + 1
        self.dmg_buff = tower.special.buff
      end
    end
    self.lasers:add(tower, index, tower_position, target_position, color)
  end
end

function PlayStageState:blinker_action(monster, dt)
  monster.blink_timer = monster.blink_timer + dt
  if monster.blink_timer > monster.special.blink_delay then
    monster.blink_timer = 0

    local sprite_instance = self.atlas:get(monster)
    local delta_s = monster.blink_distance

    sprite_instance.position:add(delta_s)
    self.lifebars:add_position(monster, delta_s)
  end
end

function PlayStageState:summoner_action(monster, dt)
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
    local sprite_instance = self.atlas:get(monster)
    local summons = monster.special.summons

    for i = 1, 4 do
      if not monster.summons_array[i] then
        local pos = sprite_instance.position
        local summoned_monster = self:_create_unit_at(summons[i], pos)
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

function PlayStageState:spawn_monsters(dt)
  if self.must_spawn_new_wave then
    self.waiting_time = self.waiting_time + dt
    if self.waiting_time < 1 then
      self.messages:write("Next wave in 5...", Vec(190, 150))
    elseif self.waiting_time < 2 then
      self.messages:write("Next wave in 4...", Vec(190, 150))
    elseif self.waiting_time < 3 then
      self.messages:write("Next wave in 3...", Vec(190, 150))
    elseif self.waiting_time < 4 then
      self.messages:write("Next wave in 2...", Vec(190, 150))
    elseif self.waiting_time < 5 then
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
    while spawn_location == self.last_spawn_location do
      spawn_location = math.random(-1, 1)
    end
    self.last_spawn_location = spawn_location

    local x, y = 7 * spawn_location, -7
    local pos = self.battlefield:tile_to_screen(x, y)

    local monster = nil
    for i, name in ipairs(self.wave.order) do
      local quantity = self.wave.quantity[i]
      if quantity > 0 then
        monster = self:_create_unit_at(name, pos)
        self.wave.quantity[i] = self.wave.quantity[i] - 1
        self.wave.delay = self.wave.cooldown[i]
        break
      else
        if self.wave.delay < 2 then
          self.wave.delay = self.wave.default_delay
        end
      end
    end

    if not monster then
      -- check if there are monsters on the field
      if next(self.monsters) == nil then
        self.current_wave = self.current_wave + 1
        self.wave_index = self.stage.waves[self.current_wave]
        self.stats.current_wave = self.current_wave

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

    if monster.blink_timer then
      self:blinker_action(monster, dt)
    else
      sprite_instance.position:add(delta_s)
      self.lifebars:add_position(monster, delta_s)
    end

    if monster.summon_timer then
      self:summoner_action(monster, dt)
    end

    if self:check_if_monster_hit_castle(monster) then
      self:take_damage(self.castle, 1)
      self:remove_unit(monster, true)
      if self.game_over then return end
    end
  end
end

function PlayStageState:manage_tower_action(dt)
  for tower in pairs(self.towers) do
    if tower.target_policy == 0 then
      --farmer
      tower.gold_timer = tower.gold_timer + dt
      if tower.gold_timer > tower.special.gold_making_delay then
        self:add_gold(tower.special.gold_to_produce)
        tower.gold_timer = 0
      end
    else
      for i, target in ipairs(tower.target_array) do
        if target then
          local distance = self:distance_to_unit(tower, target)

          if distance > tower.range then
            target.speed = target.base_speed
            self.lasers:remove(tower, i)
            self:find_target_and_add_laser(tower, i)
          else
            self:tower_do_action(tower, target)
          end
        else
          self:find_target_and_add_laser(tower, i)
        end
      end
    end
  end
end

function PlayStageState:mouse_hovering_box()
  local mouse_pos = Vec(love.mouse.getPosition())
  self.ui_select.hovered_box = nil
  self.ui_info.hovered_box = nil

  for i, box in ipairs(self.ui_select.boxes) do
    if box:is_inside(mouse_pos) then
      self.ui_select.hovered_box = box
      self.ui_info.hovered_box = box
      self.ui_info.hovered_appearance = self.ui_select.sprites[i].appearance
      self.ui_info.hovered_category = self.ui_select.sprites[i].category

      return
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
    self:mouse_hovering_box()
    self:spawn_monsters(dt)
    self:manage_tower_action(dt)
    self:position_monsters(dt)
  end
end

return PlayStageState


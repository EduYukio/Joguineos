local PROPERTIES = require 'database.properties'
local SOUNDS = require 'database.sounds'
local Vec = require 'common.vec'

local Upgrade = require 'handlers.upgrade'
local MonsterBehaviour = require 'handlers.monster_behaviour'
local TowerBehaviour = require 'handlers.tower_behaviour'
local Existence = require 'handlers.existence'

local Wave = require 'model.wave'

local Cursor = require 'view.cursor'
local SpriteAtlas = require 'view.sprite_atlas'
local BattleField = require 'view.battlefield'
local Lasers = require 'view.lasers'
local Lifebars = require 'view.lifebars'
local Messages = require 'view.messages'
local UI_Select = require 'view.ui_select'
local UI_Info = require 'view.ui_info'
local P_Systems = require 'view.p_systems'
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
  self.p_systems = nil
end

function PlayStageState:enter(params)
  self.stage = params.stage
  self:_load_handlers()
  self:_load_view()
  self:_load_units()
end

function PlayStageState:leave()
  self:view('bg'):remove('battlefield')
  self:view('fg'):remove('lasers')
  self:view('fg'):remove('atlas')
  self:view('fg'):remove('p_systems')
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
  self:add_ui_sprites()

  self.stats.number_of_waves = #self.stage.waves
  self.stats.current_wave = 1

  self.p_systems = P_Systems()

  self:view('bg'):add('battlefield', self.battlefield)
  self:view('fg'):add('lasers', self.lasers)
  self:view('fg'):add('atlas', self.atlas)
  self:view('fg'):add('p_systems', self.p_systems)
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
  self.castle = self.existence:create_unit('castle', self.castle_pos)
  self.current_wave = 1
  self.wave = Wave(self.stage.waves[self.current_wave])
  self.wave:start()
  self.monsters = {}
  self.towers = {}

  self.waiting_time = 0
  self.last_spawn_location = 1
  self.selected_tower = nil
  self.cursor.selected_tower_appearance = self.selected_tower
end

function PlayStageState:_load_handlers()
  self.upgrade = Upgrade(self)
  self.monster_behaviour = MonsterBehaviour(self)
  self.tower_behaviour = TowerBehaviour(self)
  self.existence = Existence(self)
end










function PlayStageState:add_ui_sprites()
  for _, v in pairs(self.ui_select.sprites) do
    self.atlas:add(v.name, v.pos, v.appearance)
  end

  for _, v in pairs(self.ui_info.monsters_info) do
    self.atlas:add(v.name, v.pos, v.appearance)
  end
end

function PlayStageState:add_gold(value)
  self.gold = self.gold + value
  self.stats.gold = self.gold
  self.ui_select.gold = self.gold
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
    self.existence:remove_unit(unit)
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
      self.existence:create_unit(self.selected_tower, Vec(self.cursor:get_position()))
    else
      for i, box in ipairs(self.ui_select.boxes) do
        if box:is_inside(mouse_pos) then
          local spr = self.ui_select.sprites[i]
          if spr.category == "tower" then
            self:select_tower(spr.appearance, i)
            SOUNDS.select_menu:play()
          elseif spr.category == "upgrade" then
            if spr.available and self.gold > PROPERTIES.cost[spr.name] then
              self.upgrade:units(spr.appearance)
              self:add_gold(-PROPERTIES.cost[spr.name])
              spr.available = false
              SOUNDS.buy_upgrade:play()
            else
              SOUNDS.fail:play()
            end
          end
          return
        end
      end
      self:select_tower(nil)
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
      self.messages:write("You Win!", Vec(250, 560))
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
        monster = self.existence:create_unit(name, pos)
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

function PlayStageState:manage_monsters(dt)
  for monster in pairs(self.monsters) do
    if monster.blink_timer then
      self.monster_behaviour:blinker_action(monster, dt)
    else
      self.monster_behaviour:walk(monster, dt)
    end

    if monster.summon_timer then
      self.monster_behaviour:summoner_action(monster, dt)
    end

    if self.monster_behaviour:hit_castle(monster) then
      self:take_damage(self.castle, 1)
      self.existence:remove_unit(monster, true)
      if self.game_over then return end
    end
  end
end

function PlayStageState:manage_towers(dt)
  for tower in pairs(self.towers) do
    if tower.name == "Farmer" then
      self.tower_behaviour:farmer_action(tower, dt)
    end

    for i, target in ipairs(tower.target_array) do
      if self.tower_behaviour:target_is_in_range(tower, target) then
        if tower.damage > 0 then
          self.tower_behaviour:damage_action(tower, target)
        elseif tower.special.slow then
          self.tower_behaviour:slow_action(tower, target)
        end
      else
        self.tower_behaviour:reset_status(tower, target, i)
        self.tower_behaviour:find_target(tower, i)
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
      self.messages:write("Game Over :(", Vec(230, 560))
    else
      self.game_over = false
      self.waiting_time = 0
      self:pop()
      return
    end
  else
    self.p_systems:update(dt)
    self:mouse_hovering_box()
    self:spawn_monsters(dt)
    self:manage_towers(dt)
    self:manage_monsters(dt)
  end
end

return PlayStageState


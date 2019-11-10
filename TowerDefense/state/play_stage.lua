local PROPERTIES = require 'database.properties'
local SOUNDS = require 'database.sounds'
local Vec = require 'common.vec'

local Upgrade = require 'handlers.upgrade'
local MonsterBehaviour = require 'handlers.monster_behaviour'
local TowerBehaviour = require 'handlers.tower_behaviour'
local Existence = require 'handlers.existence'
local UI_Related = require 'handlers.ui_related'
local ShowMessage = require 'handlers.show_message'
local Spawn = require 'handlers.spawn'
local Util = require 'handlers.util'

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
  self:_load_view()
  self:_load_units()
  self:_load_initial_values()
  self:_load_handlers()
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
  self.ui_info = UI_Info(Vec(right + 250, top + 10))
  self.ui_select = UI_Select(Vec(right + 32, top + 57))
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
  self.monsters = {}
  self.towers = {}
end

function PlayStageState:_load_handlers()
  self.util = Util(self)

  self.ui_related = UI_Related(self)
  self.ui_related:add_ui_sprites()

  self.existence = Existence(self)
  self.castle_pos = self.battlefield:tile_to_screen(0, 7)
  self.castle = self.existence:create_unit('castle', self.castle_pos)

  self.upgrade = Upgrade(self)
  self.monster_behaviour = MonsterBehaviour(self)
  self.tower_behaviour = TowerBehaviour(self)
  self.show_message = ShowMessage(self)
  self.spawn = Spawn(self)
end

function PlayStageState:_load_initial_values()
  self.game_over = false
  self.player_won = false
  self.must_spawn_new_wave = true

  self.selected_tower = nil
  self.cursor.selected_tower_appearance = self.selected_tower

  self.stats.number_of_waves = #self.stage.waves
  self.stats.current_wave = 1

  self.gold = self.stage.initial_gold
  self.stats.gold = self.gold
  self.ui_select.gold = self.gold
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
            self.ui_related:select_tower(spr.appearance, i)
            SOUNDS.select_menu:play()
          elseif spr.category == "upgrade" then
            if spr.available and self.gold > PROPERTIES.cost[spr.name] then
              self.upgrade:units(spr.appearance)
              self.util:add_gold(-PROPERTIES.cost[spr.name])

              spr.available = false
              SOUNDS.buy_upgrade:clone():play()
            else
              SOUNDS.fail:play()
            end
          end
          return
        end
      end
      self.ui_related:select_tower(nil)
    end
  end
end

function PlayStageState:manage_monsters_actions(dt)
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
      self.util:apply_damage(self.castle, 1)
      self.existence:remove_unit(monster, true)
      if self.game_over then return end
    end
  end
end

function PlayStageState:manage_towers_actions(dt)
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

function PlayStageState:update(dt)
  self.ui_related:highlight_hovered_box()
  self.p_systems:update(dt)
  self:manage_towers_actions(dt)

  if self.game_over then
    self.show_message:game_over(dt)
  elseif self.must_spawn_new_wave then
    self.show_message:next_wave(dt)
  elseif self.player_won then
    self.show_message:you_win(dt)
  else
    self.spawn:manage_waves(dt)
    self:manage_monsters_actions(dt)
  end
end

return PlayStageState


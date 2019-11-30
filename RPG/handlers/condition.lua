
local p = require 'database.properties'
local SOUNDS_DB = require 'database.sounds'

local Condition = require 'common.class' ()

function Condition:_init(stage)
  self.stage = stage
  self.turn = self.stage.turn
  self.players = self.stage.players
  self.p_systems = self.stage.p_systems
  self.monsters = self.stage.monsters
  self.atlas = self.stage.atlas
  self.lives = self.stage.lives
  self.rules = self.stage.rules
  self.animation = self.stage.animation
end

function Condition:check_player()
  for _, player in pairs(self.players) do
    if player.empowered then
      if self.turn - player.empowered.turn ==
         self.p_systems:get_lifetime(player, "orange") then
        player.empowered = false
      end
    end
    if player.energized then
      if self.turn - player.energized.turn ==
         self.p_systems:get_lifetime(player, "light_blue") then
        player.energized = false
      end
    end
  end
end

function Condition:check_monster()
  for i, monster in pairs(self.monsters) do
    if monster.sticky then
      if self.turn - monster.sticky.turn ==
         self.p_systems:get_lifetime(monster, "dark_blue") then
        monster.sticky = false
      end
    end
    if monster.poisoned then
      if self.turn - monster.poisoned.turn ==
         self.p_systems:get_lifetime(monster, "pure_black") then
        monster.poisoned = false
      end
      local victory = self:take_poison_dmg(monster, i)
      if victory then
        self.animation:setup_delay_animation(2.5, "Victory")
        return true
      end
    end
  end
  return false
end

function Condition:take_poison_dmg(monster, index)
  SOUNDS_DB.unit_take_hit:play()
  monster.hp = monster.hp - p.poison_dmg
  local spr = self.atlas:get(monster)
  self.lives:upgrade_life(spr, monster.hp)

  local died = self.rules:remove_if_dead(monster, self.atlas,
                    self.monsters, index, self.lives)
  local msg = monster.name .. " took " .. tostring(p.poison_dmg) ..
              " damage from poison."

  if died then
    msg = msg .. "\nIt died from bandejao's mighty fish..."
  end
  self.stage:view():get('message'):set(msg)

  if #self.monsters == 0 then
    SOUNDS_DB.fanfare:play()
    return "Victory"
  end
end

return Condition
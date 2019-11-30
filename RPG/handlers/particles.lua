
local Particles = require 'common.class' ()

function Particles:_init(stage)
  self.stage = stage
  self.players = self.stage.players
  self.monsters = self.stage.monsters
end

function Particles:emit_players_particles(dt)
  for _, player in pairs(self.players) do
    if player.crit_ensured then
      player.p_systems.dark_red:emit(1)
    end

    if player.energized then
      player.p_systems.light_blue:emit(1)
    end

    if player.empowered then
      player.p_systems.orange:emit(1)
    end

    for _, p_system in pairs(player.p_systems) do
      p_system:update(dt)
    end
  end
end

function Particles:emit_monsters_particles(dt)
  for _, monster in pairs(self.monsters) do
    if monster.charmed then
      monster.p_systems.pink:emit(1)
    end

    if monster.poisoned then
      monster.p_systems.pure_black:emit(1)
    end

    if monster.sticky then
      monster.p_systems.dark_blue:emit(1)
    end

    for _, p_system in pairs(monster.p_systems) do
      p_system:update(dt)
    end
  end
end

return Particles

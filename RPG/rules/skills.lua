return function (ruleset)

  local r = ruleset.record
  local SOUNDS_DB = require 'database.sounds'

  function ruleset.define:heal(e)
    function self.when()
      return r:is(e, 'character') and r:is(e, 'player')
    end

    function self.apply()
      local heal_amount = 10
      e.hp = math.min(e.hp + heal_amount, e.max_hp)
      e.p_systems.green:emit(60)
    end
  end

  function ruleset.define:cast_skill(e, skill, turn)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      if skill == "Heal" then
        e:heal()
        SOUNDS_DB.buff:play()
      elseif skill == "War Cry" then
        e.crit_ensured = {turn = turn}
        SOUNDS_DB.buff:play()
      elseif skill == "Charm" then
        e.charmed = {turn = turn}
        SOUNDS_DB.debuff:play()
      end
    end
  end
end
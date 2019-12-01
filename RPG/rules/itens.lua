return function (ruleset)

  local r = ruleset.record
  local SOUNDS_DB = require 'database.sounds'

  function ruleset.define:use_item(e, item, item_array, item_index, turn)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      if item == "Energy Drink" then
        e.energized = {turn = turn}
        SOUNDS_DB.buff:play()
      elseif item == "Mud Slap" then
        e.sticky = {turn = turn}
        SOUNDS_DB.debuff:play()
      elseif item == "Spinach" then
        e.empowered = {turn = turn}
        SOUNDS_DB.buff:play()
      elseif item == "Bandejao's Fish" then
        e.poisoned = {turn = turn}
        SOUNDS_DB.debuff:play()
      end
      e:remove_from_array(item_array, item_index)
    end
  end

  function ruleset.define:reset_conditions(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      for _, p_system in pairs(e.p_systems) do
        p_system:reset()
      end

      e.crit_ensured = false
      e.charmed = false
      e.poisoned = false
      e.energized = false
      e.empowered = false
      e.sticky = false
    end
  end

end
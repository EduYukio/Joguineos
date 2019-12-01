return function (ruleset)

  local r = ruleset.record
  local p = require 'database.properties'
  local SOUNDS_DB = require 'database.sounds'

  function ruleset.define:take_damage(e, amount, crit)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      local final_dmg
      local hp = e.hp

      if crit then
        SOUNDS_DB.crit_attack:play()
        final_dmg = amount + p.crit_dmg_amplifier
      elseif e.charmed then
        SOUNDS_DB.unit_take_hit:play()
        final_dmg = math.max(amount, 0)
      else
        SOUNDS_DB.unit_take_hit:play()
        final_dmg = math.max(amount - e.resistance, 0)
      end

      if final_dmg > 0 then
        hp = math.max(hp - final_dmg, 0)
        r:set(e, 'character', 'hp', hp)
      end

      return final_dmg
    end
  end

  function ruleset.define:remove_if_dead(e, atlas, unit_array, unit_index, lives)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      if e.hp <= 0 then
        SOUNDS_DB.unit_dying:play()
        local spr = atlas:get(e)
        lives:remove(spr)
        atlas:remove(e)
        for _, p_system in pairs(e.p_systems) do
          p_system:reset()
        end
        e:remove_from_array(unit_array, unit_index)
      end

      return e.hp <= 0
    end
  end

  function ruleset.define:enrage_if_dying(e, atlas)
    function self.when()
      return r:is(e, 'character') and r:is(e, "monster")
    end
    function self.apply()
      if e.enraged then return false end

      local hp_perc = e.hp/e.max_hp
      if hp_perc > 0 and hp_perc <= 0.45 then
        e.enraged = true
        e.damage = e.damage + p.enrage_dmg_amplifier
        atlas:enrage_monster(e)
        return true
      end
      return false
    end
  end

end
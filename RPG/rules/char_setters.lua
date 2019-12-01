return function (ruleset)

  local r = ruleset.record

  function ruleset.define:set_hp(e, hp)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', { hp = hp} )
    end
  end

  function ruleset.define:set_damage(e, damage)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', { damage = damage} )
    end
  end

  function ruleset.define:set_mana(e, mana)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', { mana = mana} )
    end
  end

  function ruleset.define:set_p_systems(e, p_systems)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', { p_systems = p_systems} )
    end
  end

  function ruleset.define:set_enraged(e, enraged)
    function self.when()
      return r:is(e, 'character') and r:is(e, "monster")
    end
    function self.apply()
      return r:set(e, 'character', {enraged = enraged})
    end
  end

  function ruleset.define:set_crit_ensured(e, crit_ensured)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', {crit_ensured = crit_ensured})
    end
  end

  function ruleset.define:set_charmed(e, charmed)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', {charmed = charmed})
    end
  end

  function ruleset.define:set_poisoned(e, poisoned)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', {poisoned = poisoned})
    end
  end

  function ruleset.define:set_energized(e, energized)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', {energized = energized})
    end
  end

  function ruleset.define:set_empowered(e, empowered)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', {empowered = empowered})
    end
  end

  function ruleset.define:set_sticky(e, sticky)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', {sticky = sticky})
    end
  end
end
return function (ruleset)

  local r = ruleset.record

  r:new_property('character', {
    name = "Character",
    max_hp = 15,
    hp = 15,
    damage = 10,
    resistance = 0,
    evasion = 0,
    crit_chance = 0,
    mana = 0,
    max_mana = 0,
    skill_set = {},
    appearance = "none",
    p_systems = {},

    enraged = false,
    crit_ensured = false,
    charmed = false,
    poisoned = false,
    energized = false,
    empowered = false,
    sticky = false,
  })

  r:new_property('monster', {})
  r:new_property('player', {})

  function ruleset.define:new_character(spec)
    function self.when()
      return true
    end
    function self.apply()
      local e = ruleset:new_entity()
      r:set(e, 'character', {
        name = spec.name,
        max_hp = spec.max_hp,
        hp = spec.max_hp,
        damage = spec.damage,
        resistance = spec.resistance,
        evasion = spec.evasion,
        mana = spec.max_mana,
        max_mana = spec.max_mana,
        skill_set = spec.skill_set,
        crit_chance = spec.crit_chance,
        appearance = spec.appearance,
      })

      if spec.category == "monster" then
        r:set(e, 'monster', {})
      elseif spec.category == "player" then
        r:set(e, 'player', {})
      end

      return e
    end
  end
end
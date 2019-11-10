
return {
  title = 'Campaign',
  initial_gold = 25,
  waves = {
    -- 1: Slime Intro
    { order = {"slime"},
      quantity = {10},
      cooldown = {4},
    },


    -- 2: Bat Intro
    { order = {"bat", "slime", "bat"},
      quantity = {5,  5, 10},
      cooldown = {3, .5, 2},
    },
    -- 3: Batpocalypse
    { order = {"slime", "bat", "slime", "bat"},
      quantity = { 5, 15,  5, 20},
      cooldown = {.7, .6, .6, .5},
    },


    -- 4: Golem Intro
    { order = {"golem", "golem", "bat"},
      quantity = {1, 3,  5},
      cooldown = {5, 1, .2},
    },
    -- 5: Golem+bat combo
    { order = {"golem", "slime", "bat", "golem", "bat"},
      quantity = {3,  5,  5,  6, 15,},
      cooldown = {1, .5, .5, .4, .5,},
    },


    -- 6: Blinker Intro
    { order = {"blinker", "slime", "golem", "bat", "blinker"},
      quantity = {1,  5,  2,  7,  3},
      cooldown = {7, .5,  2,  1,  4},
    },
    -- 7: Blinker+Golem combo
    { order = {"golem", "blinker", "slime", "bat", "golem", "blinker", "bat"},
      quantity = {2, 2,  7,  1,  3, 5, 7},
      cooldown = {2, 3,  1,  5, .4, 1, 2},
    },


    -- 8: Summoner Intro
    { order = {"summoner", "slime", "blinker", "golem", "bat", "summoner"},
      quantity = {1,  5, 3,  3, 10, 3},
      cooldown = {7, .5, 1, .5, .2, 1},
    },
    -- 9: Slugfest: one billion slow monsters
    { order = {"slime", "summoner", "slime", "golem", "summoner", "slime"},
      quantity = { 10, 5, 15, 3,  5, 20},
      cooldown = { .5, 1, .5, 1, .5, .5},
    },


    -- 10: GranFinale
    { order = {"slime", "bat", "golem", "blinker", "summoner",
               "slime", "golem", "blinker", "summoner", "bat"},
      quantity = { 7,  7,  7,  7,  7,  1, 15, 15, 15,  1, 30},
      cooldown = {.6, .6, .6, .6, .6, 10, .4, .4, .4,  7, .2},
    },
  }
}


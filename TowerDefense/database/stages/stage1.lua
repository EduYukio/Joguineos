
return {
  title = 'Campaign',
  initial_gold = 3000,
  waves = {
    --Slime Intro
    { order = {"slime"},
      quantity = {10},
      cooldown = {4},
    },
    --Bat Intro
    { order = {"bat", "slime", "bat"},
      quantity = {5,  5, 10},
      cooldown = {3, .5, 2},
    },
    --Batpocalypse
    -- { order = {"slime", "bat", "slime", "bat"},
    --   quantity = {5, 15,  5, 25},
    --   cooldown = {1,  1, .5, 1},
    -- },


    --Golem Intro
    { order = {"golem", "golem", "bat", "golem", "bat"},
      quantity = {1, 2,  3, 3, 10},
      cooldown = {5, 2, .5, 2, 2},
    },
    --Golem+bat combo
    { order = {"golem", "slime", "bat", "golem", "bat"},
      quantity = {3, 5, 5,  6, 10,},
      cooldown = {3, 1, 1, .4,  2,},
    },


    --Blinker Intro
    { order = {"blinker", "slime", "golem", "bat", "blinker"},
      quantity = {1,  5,  2,  7,  3},
      cooldown = {7, .5,  2,  1,  4},
    },
    --Golem+Blinker combo
    { order = {"golem", "blinker", "slime", "bat", "golem", "blinker", "bat"},
      quantity = {2, 2,  7,  1,  3, 5, 7},
      cooldown = {2, 3,  1,  5, .4, 1, 2},
    },

    --Summoner Intro
    { order = {"summoner", "slime", "blinker", "golem", "bat", "summoner"},
      quantity = {1,  5, 2, 2, 20, 3},
      cooldown = {7,  1, 2, 2,  1, 1},
    },
    --Slugfest: one billion slow monsters
    { order = {"slime", "summoner", "slime", "golem", "summoner", "slime"},
      quantity = { 10, 5, 15, 3,  5, 20},
      cooldown = { .5, 1, .5, 1, .5, .5},
    },


    --GranFinale
    { order = {"slime", "bat", "golem", "blinker", "summoner", "slime", "golem", "blinker", "summoner", "bat"},
      quantity = {15, 15, 15, 15, 15,  1,  6,  6,  6, 20},
      cooldown = {.4, .4,  2,  1,  2, 10, .3, .3, .3, .2},
    },
  }
}


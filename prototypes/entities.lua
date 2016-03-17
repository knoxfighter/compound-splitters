--entities for the compound splitter

data:extend(
{
  {
    type = "transport-belt",
    name = "cs-express-transport-belt",
    icon = "__base__/graphics/icons/express-transport-belt.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.3, result = "cs-express-transport-belt"},
    max_health = 50,
    corpse = "small-remnants",
    resistances =
    {
      {
        type = "fire",
        percent = 50
      }
    },
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/express-transport-belt.ogg",
        volume = 0.4
      },
      max_sounds_per_type = 3
    },
    animation_speed_coefficient = 32,
    animations =
    {
      filename = "__base__/graphics/entity/express-transport-belt/express-transport-belt.png",
      priority = "extra-high",
      width = 40,
      height = 40,
      frame_count = 32,
      direction_count = 12
    },
    belt_horizontal = express_belt_horizontal, -- specified in transport-belt-pictures.lua
    belt_vertical = express_belt_vertical,
    ending_top = express_belt_ending_top,
    ending_bottom = express_belt_ending_bottom,
    ending_side = express_belt_ending_side,
    starting_top = express_belt_starting_top,
    starting_bottom = express_belt_starting_bottom,
    starting_side = express_belt_starting_side,
    ending_patch = ending_patch_prototype,
    ending_patch = ending_patch_prototype,
    fast_replaceable_group = "transport-belt",
    speed = 0.09375
  },
  {
    type = "simple-entity",
    name = "compound-splitter-endcap",
    flags = {"placeable-neutral", "player-creation"},
    icon = "__compoundsplitters__/graphics/icons/water.png",--TODO:graphic
	minable = {hardness = 0.2, mining_time = 0.5, result = "compound-splitter-endcap"},
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    render_layer = "object",
    max_health = 80,
    resistances =
    {
      {
        type = "fire",
        percent = 60
      }
    },
	   pictures =
     {
       {
        filename = "__compoundsplitters__/graphics/entities/compound-splitter-endcap/compound-splitter-endcap.png",
        width = 61,
        height = 50,
		shift = {0.078125, 0.15625},
       }
	 }

  },--entry
    {
    type = "simple-entity",
    name = "compound-splitter-lane",
    flags = {"placeable-neutral", "player-creation"},
    icon = "__compoundsplitters__/graphics/icons/water.png",--TODO:graphic
	minable = {hardness = 0.2, mining_time = 0.5, result = "compound-splitter-lane"},
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    render_layer = "object",
    max_health = 80,
    resistances =
    {
      {
        type = "fire",
        percent = 60
      }
    },
	   pictures =
     {
       {
        filename = "__compoundsplitters__/graphics/entities/compound-splitter-lane/compound-splitter-lane.png",
        width = 61,
        height = 50,
		shift = {0.078125, 0.15625},
       }
	 }

  },--entry
    {
    type = "simple-entity",
    name = "compound-splitter-priority-totem",
    flags = {"placeable-neutral", "player-creation"},
    icon = "__compoundsplitters__/graphics/icons/water.png",--TODO:graphic
	minable = {hardness = 0.2, mining_time = 0.5, result = "compound-splitter-priority-totem"},
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    render_layer = "object",
    max_health = 80,
    resistances =
    {
      {
        type = "fire",
        percent = 60
      }
    },
	   pictures =
     {
       {
        filename = "__compoundsplitters__/graphics/entities/compound-splitter-priority-totem/compound-splitter-priority-totem.png",
        width = 61,
        height = 50,
		shift = {0.078125, 0.15625},
       }
	 }

  },--entry
    {
    type = "simple-entity",
    name = "compound-splitter-round-robin-totem",
    flags = {"placeable-neutral", "player-creation"},
    icon = "__compoundsplitters__/graphics/icons/water.png",--TODO:graphic
	minable = {hardness = 0.2, mining_time = 0.5, result = "compound-splitter-round-robin-totem"},
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    render_layer = "object",
    max_health = 80,
    resistances =
    {
      {
        type = "fire",
        percent = 60
      }
    },
	   pictures =
     {
       {
        filename = "__compoundsplitters__/graphics/entities/compound-splitter-round-robin-totem/compound-splitter-round-robin-totem.png",
        width = 61,
        height = 50,
		shift = {0.078125, 0.15625},
       }
	 }

  },--entry
    {
    type = "container",
    name = "compound-splitter-buffer",
    icon = "__base__/graphics/icons/steel-chest.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "compound-splitter-buffer"},
    max_health = 200,
    corpse = "small-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    resistances =
    {
      {
        type = "fire",
        percent = 90
      }
    },
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fast_replaceable_group = "container",
    inventory_size = 48,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    picture =
    {
      filename = "__compoundsplitters__/graphics/entities/compound-splitter-buffer/compound-splitter-buffer.png",
      priority = "extra-high",
      width = 62,
      height = 41,
      shift = {0.4, -0.13}
    }
  },

  
})

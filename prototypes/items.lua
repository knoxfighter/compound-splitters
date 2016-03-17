--CompoundSplitters

data:extend
({
  {
    type = "item-group",
    name = "compound-splitters",
    order = "tm",
    inventory_order = "tm",
    icon = "__compoundsplitters__/graphics/item-group/compound-splitters.png"
  },
  {
    type = "item-subgroup",
    name = "cs-belts",
    group = "compound-splitters",
    order = "a",
  },
  {
    type = "item-subgroup",
    name = "cs-blocks",
    group = "compound-splitters",
    order = "a",
  },
  {
		type = "item",
		name = "cs-express-transport-belt",
		icon = "__compoundsplitters__/graphics/icons/cs-express-transport-belt.png",
		flags = {"goes-to-quickbar"},
		subgroup = "cs-belts",
		order = "a[compound-splitters]-c[cs-express-transport-belt]",
		place_result = "cs-express-transport-belt",
		stack_size = 10
  },
  {
		type = "item",
		name = "compound-splitter-endcap",
		icon = "__compoundsplitters__/graphics/icons/compound-splitter-endcap.png",
		flags = {"goes-to-quickbar"},
		subgroup = "cs-blocks",
		order = "a[compound-splitters]-a[compound-splitter-endcap]",
		place_result = "compound-splitter-endcap",
		stack_size = 10
  },
  {
		type = "item",
		name = "compound-splitter-lane",
		icon = "__compoundsplitters__/graphics/icons/compound-splitter-lane.png",
		flags = {"goes-to-quickbar"},
		subgroup = "cs-blocks",
		order = "a[compound-splitters]-b[compound-splitter-lane]",    
		place_result = "compound-splitter-lane",    
		stack_size = 10
    },
    {
		type = "item",
		name = "compound-splitter-priority-totem",
		icon = "__compoundsplitters__/graphics/icons/compound-splitter-priority-totem.png",
		flags = {"goes-to-quickbar"},
		subgroup = "cs-blocks",
		order = "a[compound-splitters]-c[compound-splitter-priority-totem]",
		place_result = "compound-splitter-priority-totem",
		stack_size = 10
  },
    {
		type = "item",
		name = "compound-splitter-round-robin-totem",
		icon = "__compoundsplitters__/graphics/icons/compound-splitter-round-robin-totem.png",
		flags = {"goes-to-quickbar"},
		subgroup = "cs-blocks",
		order = "a[compound-splitters]-d[compound-splitter-round-robin-totem]",
		place_result = "compound-splitter-round-robin-totem",
		stack_size = 10
    },
    {
		type = "item",
		name = "compound-splitter-buffer",
		icon = "__compoundsplitters__/graphics/icons/compound-splitter-buffer.png",
		flags = {"goes-to-quickbar"},
		subgroup = "cs-blocks",
		order = "a[compound-splitters]-e[compound-splitter-buffer]",
		place_result = "compound-splitter-buffer",
		stack_size = 10
  }
})


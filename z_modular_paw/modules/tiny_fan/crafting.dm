// Recipe for Tiny Fan
/datum/crafting_recipe/tiny_fan
	name = "Tiny Fan"
	tool_behaviors = list(TOOL_WRENCH) // wrench to make, wrench to dismantle
	result = /obj/structure/fans/tiny
	time = 4 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stock_parts/manipulator = 1,
	)
	category = CAT_STRUCTURE

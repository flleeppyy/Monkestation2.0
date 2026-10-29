/obj/item/slimecross/Initialize(mapload)
	. = ..()
	var/datum/slime_type/slime_type = GLOB.slime_colors_to_types[colour]
	if(slime_type && slime_type::visual_effect)
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
		add_visual_effect(slime_type::visual_effect)

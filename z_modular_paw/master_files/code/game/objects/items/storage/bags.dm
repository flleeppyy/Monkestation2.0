// SLIME_RANCHER - science bags carry breeding pellets too
/obj/item/storage/bag/xeno/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(assoc_to_keys(atom_storage.can_hold) + /obj/item/slime_breeding_pellet)

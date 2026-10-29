// maps still place slimecore's xenobio gear - these stand-ins turn it into slime rancher gear at load, so no map edits needed

/// slimecore slimes were mapped with a color datum instead of a slime type, read in Initialize
/mob/living/basic/slime
	var/datum/slime_color/current_color

/datum/slime_color
	var/datum/slime_type/slime_type

/datum/slime_color/bluespace
	slime_type = /datum/slime_type/bluespace

/// Four corners sharing a mapping_id (on one z-level) become one slime pen: the rectangle strictly inside them.
/// The old fence line stays plain floor, and neighboring pens that shared corner tiles each get their own.
/obj/machinery/corral_corner
	name = "corral fencepost"
	var/mapping_id

/obj/machinery/corral_corner/Initialize(mapload)
	. = ..()
	// a corner spawned mid-round has no group to join
	return mapload ? INITIALIZE_HINT_LATELOAD : INITIALIZE_HINT_QDEL

/obj/machinery/corral_corner/LateInitialize()
	if(QDELETED(src))
		return
	var/list/obj/machinery/corral_corner/group = list()
	var/list/turf/corner_turfs = list()
	for(var/obj/machinery/corral_corner/corner as anything in SSmachines.get_machines_by_type(/obj/machinery/corral_corner))
		if(!QDELETED(corner) && corner.mapping_id == mapping_id && corner.z == z)
			group += corner
			corner_turfs += get_turf(corner)
	if(mapping_id)
		convert_legacy_corral(corner_turfs)
	QDEL_LIST(group)

/// Builds the pen strictly inside four corral corner tiles. Returns the pen, or null if the corners don't make one.
/proc/convert_legacy_corral(list/turf/corner_turfs)
	if(length(corner_turfs) != 4)
		return null
	var/list/xs = list()
	var/list/ys = list()
	for(var/turf/corner as anything in corner_turfs)
		xs += corner.x
		ys += corner.y
	var/z = corner_turfs[1].z
	var/min_x = min(xs) + 1
	var/min_y = min(ys) + 1
	var/max_x = max(xs) - 1
	var/max_y = max(ys) - 1
	if(min_x > max_x || min_y > max_y)
		return null
	var/list/interior = block(locate(min_x, min_y, z), locate(max_x, max_y, z))
	// a one-tile-wide pen puts several posts on the same tile, so this can't be keyed by turf
	var/list/post_spots = list(
		list(locate(min_x, min_y, z), SOUTHWEST),
		list(locate(max_x, min_y, z), SOUTHEAST),
		list(locate(min_x, max_y, z), NORTHWEST),
		list(locate(max_x, max_y, z), NORTHEAST),
	)
	var/list/obj/structure/slime_pen_post/posts = list()
	for(var/list/spot as anything in post_spots)
		var/obj/structure/slime_pen_post/post = new(spot[1])
		post.set_anchored(TRUE)
		post.setDir(spot[2])
		post.update_offsets()
		posts += post
	return new /datum/slime_pen(interior, posts)

/obj/machinery/slime_compressor

/obj/machinery/slime_compressor/Initialize(mapload)
	. = ..()
	var/obj/machinery/extract_compressor/compressor = new(loc)
	compressor.setDir(dir)
	return INITIALIZE_HINT_QDEL

/obj/item/vacuum_pack/backpack

/obj/item/disk/vacuum_upgrade/biomass
	name = "vacuum printer upgrade disk"
	upgrade_type = /datum/vacuum_upgrade/printer

// slimecore's pen consoles, market and extract request pads have no rancher counterpart
/obj/machinery/slime_pen_controller
	var/mapping_id

/obj/machinery/slime_pen_controller/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/machinery/slime_market_pad/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/machinery/computer/slime_market/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/machinery/slime_extract_requestor/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_QDEL

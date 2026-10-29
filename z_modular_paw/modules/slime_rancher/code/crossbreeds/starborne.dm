#define STARBORNE_ORBIT_RADIUS 20
#define STARBORNE_ORBIT_TIME (4 SECONDS)
/// How long a thrown weapon sits where it landed before it heads back.
#define STARBORNE_RETURN_DELAY (0.3 SECONDS)
/// How long the glide back to the thrower takes.
#define STARBORNE_RETURN_TIME (0.5 SECONDS)
/// How long a thrown weapon stays embedded in someone before it tears itself out.
#define STARBORNE_EMBED_TIME (2 SECONDS)

/// A weapon with this circles whoever dropped or threw it, like a tiny moon, until someone picks it up.
/datum/element/starborne

/datum/element/starborne/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	var/obj/item/weapon = target
	weapon.name = "starborne [weapon.name]"
	weapon.add_visual_effect(/obj/effect/abstract/visual_effect/spacey)
	RegisterSignal(weapon, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(weapon, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(on_throw_landed))

/datum/element/starborne/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_THROW_LANDED))
	return ..()

/datum/element/starborne/proc/on_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	// a throw drops the item first and only starts flying after. wait a tick so we can tell the two apart
	addtimer(CALLBACK(src, PROC_REF(orbit_dropper), source, user), 0)

/datum/element/starborne/proc/orbit_dropper(obj/item/weapon, mob/dropper)
	if(QDELETED(weapon) || QDELETED(dropper) || weapon.throwing)
		return
	if(!isturf(weapon.loc) || weapon.loc != dropper.loc)
		return
	weapon.orbit(dropper, radius = STARBORNE_ORBIT_RADIUS, clockwise = TRUE, rotation_speed = STARBORNE_ORBIT_TIME, pre_rotation = FALSE)

/datum/element/starborne/proc/on_throw_landed(obj/item/source, datum/thrownthing/throwing_datum)
	SIGNAL_HANDLER
	var/mob/thrower = throwing_datum.thrower
	if(QDELETED(thrower))
		return
	if(source.get_embed()?.owner)
		addtimer(CALLBACK(src, PROC_REF(tear_free), source, thrower), STARBORNE_EMBED_TIME)
		return
	if(!isturf(source.loc))
		return
	addtimer(CALLBACK(src, PROC_REF(fly_back), source, thrower), STARBORNE_RETURN_DELAY)

/datum/element/starborne/proc/tear_free(obj/item/weapon, mob/thrower)
	if(QDELETED(weapon) || QDELETED(thrower))
		return
	var/datum/embedding/embed = weapon.get_embed()
	if(embed?.owner)
		embed.owner.visible_message(
			span_danger("[weapon] tears itself free from [embed.owner]'s [embed.owner_limb.plaintext_zone]!"),
			span_userdanger("[weapon] tears itself free from your [embed.owner_limb.plaintext_zone]!"),
		)
		if(!embed.is_harmless())
			embed.damaging_removal_effect(1)
		// the damage can take the whole limb off, and a severed limb already spits the weapon out
		if(embed.owner)
			embed.remove_embedding()
	fly_back(weapon, thrower)

/datum/element/starborne/proc/fly_back(obj/item/weapon, mob/thrower)
	if(QDELETED(weapon) || QDELETED(thrower) || weapon.throwing || weapon.orbiting || !isturf(weapon.loc))
		return
	var/turf/landed = weapon.loc
	var/turf/destination = get_turf(thrower)
	if(isnull(destination))
		return
	// the weapon really teleports right now, the trip back is nothing but pixel offsets
	weapon.abstract_move(destination)
	weapon.pixel_w = (landed.x - destination.x) * ICON_SIZE_X
	weapon.pixel_z = (landed.y - destination.y) * ICON_SIZE_Y
	// an orbit starts at the top of its circle, so the glide ends there instead of popping at the handoff
	animate(weapon, pixel_w = 0, pixel_z = STARBORNE_ORBIT_RADIUS, time = STARBORNE_RETURN_TIME, easing = CUBIC_EASING|EASE_OUT)
	addtimer(CALLBACK(src, PROC_REF(finish_return), weapon, thrower), STARBORNE_RETURN_TIME)

/datum/element/starborne/proc/finish_return(obj/item/weapon, mob/thrower)
	if(QDELETED(weapon))
		return
	weapon.pixel_z = 0
	if(QDELETED(thrower) || weapon.throwing || !isturf(weapon.loc))
		return
	weapon.orbit(thrower, radius = STARBORNE_ORBIT_RADIUS, clockwise = TRUE, rotation_speed = STARBORNE_ORBIT_TIME, pre_rotation = FALSE)

#undef STARBORNE_ORBIT_RADIUS
#undef STARBORNE_ORBIT_TIME
#undef STARBORNE_RETURN_DELAY
#undef STARBORNE_RETURN_TIME
#undef STARBORNE_EMBED_TIME

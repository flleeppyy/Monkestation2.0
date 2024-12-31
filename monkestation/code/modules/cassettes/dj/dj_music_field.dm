/// A proximity monitor field that allows mobs near objects to hear DJ music.
/datum/proximity_monitor/advanced/dj_music
	edge_is_a_field = TRUE
	/// List of mobs that can currently hear music from this field.
	var/list/mob/listeners

/datum/proximity_monitor/advanced/dj_music/Destroy()
	for(var/mob/listener as anything in listeners)
		remove_mob(listener)
	return ..()

/datum/proximity_monitor/advanced/dj_music/field_turf_crossed(mob/living/crosser, turf/old_location, turf/new_location)
	if(isliving(crosser))
		add_mob(crosser)

/datum/proximity_monitor/advanced/dj_music/field_turf_uncrossed(mob/living/crosser, turf/old_location, turf/new_location)
	if(isliving(crosser))
		remove_mob(crosser)

/datum/proximity_monitor/advanced/dj_music/setup_field_turf(turf/target)
	for(var/mob/living/inner_mob as anything in target)
		add_mob(inner_mob)

/datum/proximity_monitor/advanced/dj_music/cleanup_field_turf(turf/target)
	for(var/mob/living/inner_mob as anything in target)
		remove_mob(inner_mob)

/datum/proximity_monitor/advanced/dj_music/proc/add_mob(mob/living/target)
	if(QDELING(src) || !isliving(target) || QDELING(target) || (target in listeners))
		return
	LAZYADD(listeners, target)
	ADD_TRAIT(target, TRAIT_CAN_HEAR_MUSIC, REF(src))
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(remove_mob))

/datum/proximity_monitor/advanced/dj_music/proc/remove_mob(mob/living/target)
	if(!isliving(target) || !(target in listeners))
		return
	LAZYREMOVE(listeners, target)
	REMOVE_TRAIT(target, TRAIT_CAN_HEAR_MUSIC, REF(src))
	UnregisterSignal(target, COMSIG_QDELETING)

// SLIME_RANCHER - getting eaten flips a monkey into the combat subtree, which screeches from its own list.
// penned ones use their quiet idle emotes instead.
/datum/ai_behavior/battle_screech/monkey/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!controller.blackboard[BB_MONKEY_PENNED])
		return ..()
	var/datum/idle_behavior/idle_monkey/penned/quiet = controller.idle_behavior
	INVOKE_ASYNC(controller.pawn, TYPE_PROC_REF(/mob, emote), pick(quiet.common_emotes))
	finish_action(controller, TRUE)

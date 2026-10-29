#define SLIME_REACTION_MOOD_DURATION (10 SECONDS)
#define SLIME_MOOD_GRUDGE_TIME (30 SECONDS)
#define SLIME_MOOD_HURT_RATIO 0.5

/mob/living/basic/slime
	COOLDOWN_DECLARE(reaction_mood_cooldown)

/mob/living/basic/slime/proc/set_mood(new_mood)
	if(current_mood == new_mood)
		return
	var/old_mood = current_mood
	current_mood = new_mood
	SEND_SIGNAL(src, COMSIG_SLIME_UPDATE_MOOD, old_mood, new_mood)
	regenerate_icons()

/mob/living/basic/slime/proc/set_temporary_mood(new_mood, duration = SLIME_REACTION_MOOD_DURATION)
	if(client)
		return
	COOLDOWN_START(src, reaction_mood_cooldown, duration)
	set_mood(new_mood)

/mob/living/basic/slime/proc/update_mood()
	if(client || !COOLDOWN_FINISHED(src, reaction_mood_cooldown))
		return
	set_mood(get_resting_mood())

/mob/living/basic/slime/proc/get_resting_mood()
	if(isnull(ai_controller))
		return SLIME_MOOD_NONE

	var/list/blackboard = ai_controller.blackboard
	if(blackboard[BB_SLIME_RABID])
		return SLIME_MOOD_ANGRY // angy
	if(was_recently_attacked())
		return hunger_disabled ? SLIME_MOOD_SAD : SLIME_MOOD_ANGRY // womp womp
	if(health < maxHealth * SLIME_MOOD_HURT_RATIO)
		return SLIME_MOOD_SAD
	if(!hunger_disabled && blackboard[BB_SLIME_HUNGER_LEVEL] == SLIME_HUNGER_STARVING)
		return SLIME_MOOD_SAD
	if(blackboard[BB_SLIME_EAT_TARGET] || blackboard[BB_SLIME_ITEM_TARGET])
		return SLIME_MOOD_MISCHIEVOUS
	if(!hunger_disabled && blackboard[BB_SLIME_HUNGER_LEVEL] == SLIME_HUNGER_HUNGRY)
		return SLIME_MOOD_POUT
	if(cat_slime)
		return SLIME_MOOD_CAT
	if(hunger_disabled || nutrition >= SLIME_GROW_NUTRITION)
		return SLIME_MOOD_SMILE
	return SLIME_MOOD_NONE

/mob/living/basic/slime/proc/was_recently_attacked()
	var/list/grudges = ai_controller?.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	for(var/attacker in grudges)
		if(world.time - grudges[attacker] <= SLIME_MOOD_GRUDGE_TIME)
			return TRUE
	return FALSE

/mob/living/basic/slime/proc/on_petted(mob/living/basic/slime/source, mob/living/petter)
	SIGNAL_HANDLER
	if(isliving(buckled)) // you're not petting it, you're prying it off someone
		return
	if(current_mood == SLIME_MOOD_SAD && !COOLDOWN_FINISHED(src, reaction_mood_cooldown))
		return
	set_temporary_mood((petter in ai_controller?.blackboard[BB_FRIENDS_LIST]) ? SLIME_MOOD_CAT : SLIME_MOOD_SMILE)

/mob/living/basic/slime/proc/on_slime_happy_yay(datum/source)
	SIGNAL_HANDLER
	set_temporary_mood(SLIME_MOOD_SMILE)

#undef SLIME_MOOD_GRUDGE_TIME
#undef SLIME_MOOD_HURT_RATIO
#undef SLIME_REACTION_MOOD_DURATION

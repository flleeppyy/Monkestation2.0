/// How far away a friend can open a slime's command menu from. Same as how far voice commands carry.
#define SLIME_COMMAND_MENU_RANGE 7

// SLIME_RANCHER - slimes take alt-click orders from across the room, since ur voice doesn't reach into pens
/datum/component/obeys_commands/display_menu(datum/source, mob/living/clicker)
	var/mob/living/living_parent = parent
	if(!isslime(living_parent))
		return ..()
	if(IS_DEAD_OR_INCAP(living_parent) || !clicker.can_perform_action(living_parent, BYPASS_ADJACENCY))
		return
	if(!can_see(living_parent, clicker, SLIME_COMMAND_MENU_RANGE))
		return
	if(!(clicker in living_parent.ai_controller?.blackboard[BB_FRIENDS_LIST]))
		return
	INVOKE_ASYNC(src, PROC_REF(display_radial_menu), clicker)

#undef SLIME_COMMAND_MENU_RANGE

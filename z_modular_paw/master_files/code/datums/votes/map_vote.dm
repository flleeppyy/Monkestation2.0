// fancy tiebreaker doohickey - recent maps lose to less recent maps.
/datum/vote/map_vote/tiebreaker(list/winners)
	var/list/least_recent = winners.Copy()
	for(var/recent_map in list(SSmapping.current_map.map_name) + SSpersistence.saved_maps)
		if(length(least_recent) == 1)
			break
		least_recent -= recent_map
	return pick(least_recent)

/datum/vote/map_vote/finalize_vote(winning_option)
	if(SSmap_vote.already_voted)
		message_admins("Attempted to finalize a map vote after a map vote has already been finalized.")
		return
	SSmap_vote.already_voted = TRUE

	if(SSmap_vote.admin_override)
		SSmap_vote.send_map_vote_notice("Admin Override is in effect. Map will not be changed.")
		return

	if(!SSmap_vote.set_next_map(global.config.maplist[winning_option]))
		return

	var/list/messages = list("Map Selected - [span_bold(winning_option)]", "Votes:")
	for(var/option in choices)
		messages += "[option] - [choices[option]]"
	SSmap_vote.send_map_vote_notice(arglist(messages))

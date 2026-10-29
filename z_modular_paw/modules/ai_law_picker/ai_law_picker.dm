// Lets the AI choose it's starting lawset from those that are enabled.

/mob/living/silicon/ai/proc/ai_law_picker()
	if(!client)
		return

	var/list/law_options = list()
	var/list/law_weights = CONFIG_GET(keyed_list/law_weight)
	for(var/lawid in law_weights)
		if(law_weights[lawid] <= 0) // Weight is 0 == disabled
			continue
		var/law_type = lawid_to_type(lawid)
		if(!law_type)
			continue
		var/datum/ai_laws/eligible_lawset = law_type
		law_options[initial(eligible_lawset.name)] = law_type

	if(!length(law_options))
		return

	var/chosen_lawset = tgui_input_list(src, "Choose your starting lawset. Closing this window will keep your default.", "Lawset Selection", sort_list(law_options), timeout = 120 SECONDS)
	if(isnull(chosen_lawset) || QDELETED(src))
		return
	var/law_type = law_options[chosen_lawset]
	var/datum/ai_laws/old_laws = laws
	laws = new law_type
	laws.associate(src)
	qdel(old_laws)

	var/law_check = list()
	for(var/law in laws.inherent)
		law_check += law

	to_chat(src, span_boldnotice("Lawset [chosen_lawset] has been selected."))
	show_laws()

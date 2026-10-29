/datum/preference/choiced/junkie_drug_choice
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "junkie_drug_choice"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	should_update_preview = FALSE

/datum/preference/choiced/junkie_drug_choice/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.junkie_drugs)

/datum/preference/choiced/junkie_drug_choice/create_default_value()
	return "Random"

/datum/preference/choiced/junkie_drug_choice/is_accessible(datum/preferences/preferences)
	return ..() && (/datum/quirk/item_quirk/junkie::name in preferences.all_quirks)

/datum/preference/choiced/junkie_drug_choice/apply_to_human(mob/living/carbon/human/target, value)
	return

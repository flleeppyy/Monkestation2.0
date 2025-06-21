// This list is non-exhaustive
GLOBAL_LIST_INIT(pronouns_valid, list(
	"he", "him", "his",
	"she","her","hers",
	"hyr", "hyrs",
	"they", "them", "their","theirs",
	"it", "it", "its",
	"xey", "xe", "xem", "xyr", "xyrs",
	"ze", "zir", "zirs",
	"ey", "em", "eir", "eirs",
	"fae", "faer", "faers",
	"ve", "ver", "vis", "vers",
	"ne", "nem", "nir", "nirs",
	"mrr", "mrrp", "mrrs", "mrrs",
	"fox", "foxs", "foxes",
	"bun", "buns",
	"cat", "puppy"
))

// list of pronouns where one of them must be used in a pronouns field, so someone cant just do "fox/cat/bun"
GLOBAL_LIST_INIT(pronouns_required, list(
	"he", "she", "they", "it", "xey", "ze", "ey", "fae", "ve", "ne",
))

/// The color admins will speak in for OOC.
/datum/preference/color/ooc_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "ooccolor"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/color/ooc_color/create_default_value()
	return "#c43b23"

/datum/preference/color/ooc_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return is_admin(preferences.parent) || preferences.unlock_content

/datum/preference/text/ooc_pronouns
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "oocpronouns"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/text/ooc_pronouns/create_default_value()
	return ""

/datum/preference/text/is_valid(value)
	if (!value || trim(value) == "")
		return TRUE

	var/pronouns = splittext(value, "/")
	if (length(pronouns) > 8)
		to_chat(usr, "You can only set up to 8 different pronouns.")
		return FALSE
	for (var/pronoun in pronouns)
		if (!(pronoun in GLOB.pronouns_valid))
			to_chat(usr, span_warning("Invalid pronoun: [pronoun]. Valid pronouns are: [GLOB.pronouns_valid.Join(", ")]"))
			return FALSE

	if (length(pronouns) != length(unique_list(pronouns)))
		to_chat(usr, span_warning("You cannot use the same pronoun multiple times."))
		return FALSE

	for (var/pronoun in GLOB.pronouns_required)
		if (pronoun in pronouns)
			return TRUE

	to_chat(usr, span_warning("You must include at least one of the following pronouns: [GLOB.pronouns_required.Join(", ")]"))
	// Someone may yell at me i dont know
	return FALSE

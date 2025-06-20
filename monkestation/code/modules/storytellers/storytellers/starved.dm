// Check /mob/living/proc/death :)
/datum/storyteller/starved
	name = "The Starved"
	desc = "The Starved will create events based on crew death. THe more crew that die, the more powerful the events become."
	// Purposefully have shit multipliers because
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 0.5,
		EVENT_TRACK_MODERATE = 0.5,
		EVENT_TRACK_MAJOR = 0.5,
		EVENT_TRACK_ROLESET = 1,
		EVENT_TRACK_OBJECTIVES = 1
	)
	ignores_roundstart = TRUE
	population_min = 40
	welcome_text = "You feel a hunger in the air."
	weight = 1
	points_per_death = 10


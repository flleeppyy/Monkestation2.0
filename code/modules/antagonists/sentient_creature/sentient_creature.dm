/datum/antagonist/sentient_creature
	name = "\improper Sentient Creature"
	show_in_antagpanel = FALSE
	show_in_roundend = FALSE
	count_against_dynamic_roll_chance = FALSE
	ui_name = "AntagInfoSentient"
	antag_flags = FLAG_ANTAG_CAP_IGNORE // monkestation addition

/datum/antagonist/sentient_creature/get_preview_icon()
	var/icon/final_icon = icon('icons/mob/simple/pets.dmi', "corgi")

	var/icon/pandora = icon('icons/mob/simple/lavaland/lavaland_elites.dmi', "pandora")
	pandora.Blend(rgb(128, 128, 128, 128), ICON_MULTIPLY)
	final_icon.Blend(pandora, ICON_UNDERLAY, -world.icon_size / 4, 0)

	var/icon/rat = icon('icons/mob/simple/animal.dmi', "regalrat")
	rat.Blend(rgb(128, 128, 128, 128), ICON_MULTIPLY)
	final_icon.Blend(rat, ICON_UNDERLAY, world.icon_size / 4, 0)

	final_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	return final_icon

/datum/antagonist/sentient_creature/on_gain()
	var/mob/living/master = owner.enslaved_to?.resolve()
	if(master)
		owner.current.copy_languages(master, LANGUAGE_MASTER)
		owner.current.update_atom_languages()
	. = ..()

/datum/antagonist/sentient_creature/ui_static_data(mob/user)
	var/list/data = list()
	var/mob/living/master = owner.enslaved_to?.resolve()
	if(master)
		data["enslaved_to"] = master.real_name
		data["p_them"] = master.p_them()
		data["p_their"] = master.p_their()
	data["holographic"] = owner.current.flags_1 & HOLOGRAM_1
	return data

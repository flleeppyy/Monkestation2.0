// Describes the three modes of scanning available for health analyzers
#define SCANMODE_HEALTH 0
#define SCANMODE_WOUND 1
#define SCANMODE_COUNT 2 // Update this to be the number of scan modes if you add more
#define SCANNER_CONDENSED 0
#define SCANNER_VERBOSE 1
// Not updating above count because you're not meant to switch to this mode.
#define SCANNER_NO_MODE -1

/obj/item/healthanalyzer
	name = "health analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	inhand_icon_state = "healthanalyzer"
	worn_icon_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held body scanner capable of distinguishing vital signs of the subject. Has a side button to scan for chemicals, and can be toggled to scan wounds."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT *2)
	var/mode = SCANNER_VERBOSE
	var/scanmode = SCANMODE_HEALTH
	var/advanced = FALSE
	custom_price = PAYCHECK_COMMAND
	/// If this analyzer will give a bonus to wound treatments apon woundscan.
	var/give_wound_treatment_bonus = FALSE
	var/last_scan_text

/obj/item/healthanalyzer/Initialize(mapload)
	. = ..()
	register_item_context()

/obj/item/healthanalyzer/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to toggle the limb damage readout.")

/obj/item/healthanalyzer/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!"))
	return BRUTELOSS

/obj/item/healthanalyzer/attack_self(mob/user)
	if(!user.can_read(src) || user.is_blind())
		return

	scanmode = (scanmode + 1) % SCANMODE_COUNT
	switch(scanmode)
		if(SCANMODE_HEALTH)
			to_chat(user, span_notice("You switch the health analyzer to check physical health."))
		if(SCANMODE_WOUND)
			to_chat(user, span_notice("You switch the health analyzer to report extra info on wounds."))

/obj/item/healthanalyzer/attack(mob/living/M, mob/living/carbon/human/user)
	if(!user.can_read(src) || user.is_blind())
		return

	flick("[icon_state]-scan", src) //makes it so that it plays the scan animation upon scanning, including clumsy scanning

	// Clumsiness/brain damage check
	if ((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
		var/turf/scan_turf = get_turf(user)
		user.visible_message(
			span_warning("[user] analyzes [scan_turf]'s vitals!"),
			span_notice("You stupidly try to analyze [scan_turf]'s vitals!"),
		)

		var/floor_text = "<span class='info'>Analyzing results for <b>[scan_turf]</b> ([station_time_timestamp()]):</span><br>"
		floor_text += "<span class='info ml-1'>Overall status: <i>Unknown</i></span><br>"
		floor_text += "<span class='alert ml-1'>Subject lacks a brain.</span><br>"
		floor_text += "<span class='info ml-1'>Body temperature: [scan_turf?.return_air()?.return_temperature() || "???"]</span><br>"

		if(user.can_read(src) && !user.is_blind())
			to_chat(user, boxed_message(floor_text))
		last_scan_text = floor_text
		return

	if(ispodperson(M) && !advanced)
		to_chat(user, "<span class='info'>[M]'s biological structure is too complex for the health analyzer.")
		return

	user.visible_message(span_notice("[user] analyzes [M]'s vitals."))
	balloon_alert(user, "analyzing vitals")
	playsound(user.loc, 'sound/items/healthanalyzer.ogg', 50)

	var/readability_check = user.can_read(src) && !user.is_blind()
	switch(scanmode)
		if(SCANMODE_HEALTH)
			last_scan_text = healthscan(user, M, mode, advanced, tochat = readability_check)
		if(SCANMODE_WOUND)
			if(readability_check)
				woundscan(user, M, src)

	add_fingerprint(user)

/obj/item/healthanalyzer/attack_secondary(mob/living/victim, mob/living/user, params)
	if(user.can_read(src) && !user.is_blind())
		chemscan(user, victim)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/healthanalyzer/add_item_context(
	obj/item/source,
	list/context,
	atom/target,
)
	if (!isliving(target))
		return NONE

	switch (scanmode)
		if (SCANMODE_HEALTH)
			context[SCREENTIP_CONTEXT_LMB] = "Scan health"
		if (SCANMODE_WOUND)
			context[SCREENTIP_CONTEXT_LMB] = "Scan wounds"

	context[SCREENTIP_CONTEXT_RMB] = "Scan chemicals"

	return CONTEXTUAL_SCREENTIP_SET

/**
 * healthscan
 * returns a list of everything a health scan should give to a player.
 * Examples of where this is used is Health Analyzer and the Physical Scanner tablet app.
 * Args:
 * user - The person with the scanner
 * target - The person being scanned
 * mode - Uses SCANNER_CONDENSED or SCANNER_VERBOSE to decide whether to give a list of all individual limb damage
 * advanced - Whether it will give more advanced details, such as husk source.
 * tochat - Whether to immediately post the result into the chat of the user, otherwise it will return the results.
 */
/proc/healthscan(mob/user, mob/living/target, mode = SCANNER_VERBOSE, advanced = FALSE, tochat = TRUE)
	if(user.incapacitated())
		return

	// the final list of strings to render
	var/list/render_list = list()

	// Damage specifics
	var/oxy_loss = target.getOxyLoss()
	var/tox_loss = target.getToxLoss()
	var/fire_loss = target.getFireLoss()
	var/brute_loss = target.getBruteLoss()
	var/mob_status = (target.stat == DEAD ? span_alert("<b>Deceased</b>") : "<b>[round(target.health / target.maxHealth, 0.01) * 100]% healthy</b>")

	if(HAS_TRAIT(target, TRAIT_FAKEDEATH) && !advanced)
		mob_status = span_alert("<b>Deceased</b>")
		oxy_loss = max(rand(1, 40), oxy_loss, (300 - (tox_loss + fire_loss + brute_loss))) // Random oxygen loss

	render_list += "[span_info("Analyzing results for <b>[target]</b> ([station_time_timestamp()]):")]<br><span class='info ml-1'>Overall status: [mob_status]</span><br>"

	if(!advanced && target.has_reagent(/datum/reagent/inverse/technetium))
		advanced = TRUE

	SEND_SIGNAL(target, COMSIG_LIVING_HEALTHSCAN, render_list, advanced, user, mode, tochat)

	// Husk detection
	if(HAS_TRAIT(target, TRAIT_HUSK))
		if(advanced)
			if(HAS_TRAIT_FROM(target, TRAIT_HUSK, BURN))
				render_list += "<span class='alert ml-1'>Subject has been husked by [conditional_tooltip("severe burns", "Tend burns and apply a de-husking agent, such as [/datum/reagent/medicine/c2/synthflesh::name].", tochat)].</span><br>"
			else if (HAS_TRAIT_FROM(target, TRAIT_HUSK, CHANGELING_DRAIN))
				render_list += "<span class='alert ml-1'>Subject has been husked by [conditional_tooltip("desiccation", "Irreparable. Under normal circumstances, revival can only proceed via brain transplant, cloning, or special surgies.", tochat)].</span><br>"
			else
				render_list += "<span class='alert ml-1'>Subject has been husked by mysterious causes.</span>\n"

		else
			render_list += "<span class='alert ml-1'>Subject has been husked.</span>\n"

	// monkestation edit: no-heal challenge
	if(HAS_TRAIT(target, TRAIT_NO_HEALS))
		render_list += "<span class='alert ml-1'><b>Subject cannot be healed by any known methods.</b></span>\n"
	// monkestation end

	// monkestation edit: heavy bleeder challenge
	if(HAS_TRAIT(target, TRAIT_HEAVY_BLEEDER))
		render_list += "<span class='alert ml-1'><b>Subject will suffer highly abnormal hemorrhaging from laceration or surgical incension.</b></span>\n"

	// monkestation edit: DNR Quirk, i mean it also technically will count for all other defib blacklist reasons.
	if(HAS_TRAIT(target, TRAIT_DEFIB_BLACKLISTED))
		render_list += "<span class='alert ml-1'><b>Subject is blacklisted from resuscitation and cannot be defibrillated[target.stat == DEAD ? "" : " after dying"].</b></span>\n"
	// monkestation end

	if(target.stamina.loss)
		if(advanced)
			render_list += "<span class='alert ml-1'>Fatigue level: [target.stamina.loss]%.</span>\n"
		else
			render_list += "<span class='alert ml-1'>Subject appears to be suffering from fatigue.</span>\n"
	if (target.getCloneLoss())
		if(advanced)
			render_list += "<span class='alert ml-1'>Cellular damage level: [target.getCloneLoss()].</span>\n"
		else
			render_list += "<span class='alert ml-1'>Subject appears to have [target.getCloneLoss() > 30 ? "severe" : "minor"] cellular damage.</span>\n"
	if (!target.get_organ_slot(ORGAN_SLOT_BRAIN)) // kept exclusively for soul purposes
		render_list += "<span class='alert ml-1'>Subject lacks a brain.</span>\n"

	if(iscarbon(target))
		var/mob/living/carbon/carbontarget = target
		if(LAZYLEN(carbontarget.quirks))
			render_list += "<span class='info ml-1'>Subject Major Disabilities: [carbontarget.get_quirk_string(FALSE, CAT_QUIRK_MAJOR_DISABILITY, from_scan = TRUE)].</span>\n"
			if(advanced)
				render_list += "<span class='info ml-1'>Subject Minor Disabilities: [carbontarget.get_quirk_string(FALSE, CAT_QUIRK_MINOR_DISABILITY, TRUE)].</span>\n"

	// Body part damage report
	if(iscarbon(target))
		var/mob/living/carbon/carbontarget = target
		var/any_damage = brute_loss > 0 || fire_loss > 0 || oxy_loss > 0 || tox_loss > 0 || fire_loss > 0
		var/any_missing = length(carbontarget.bodyparts) < (carbontarget.dna?.species?.max_bodypart_count || 6)
		var/any_wounded = length(carbontarget.all_wounds)
		var/any_embeds = carbontarget.has_embedded_objects()
		if(any_damage || (mode == SCANNER_VERBOSE && (any_missing || any_wounded || any_embeds)))
			render_list += "<hr>"
			var/dmgreport = "<span class='info ml-1'>Body status:</span>\
							<font face='Verdana'>\
							<table class='ml-2'>\
							<tr>\
							<td style='width:7em;'><font color='#ff0000'><b>Damage:</b></font></td>\
							<td style='width:5em;'><font color='#ff3333'><b>Brute</b></font></td>\
							<td style='width:4em;'><font color='#ff9933'><b>Burn</b></font></td>\
							<td style='width:4em;'><font color='#00cc66'><b>Toxin</b></font></td>\
							<td style='width:8em;'><font color='#00cccc'><b>Suffocation</b></font></td>\
							</tr>\
							<tr>\
							<td><font color='#ff3333'><b>Overall:</b></font></td>\
							<td><font color='#ff3333'><b>[ceil(brute_loss)]</b></font></td>\
							<td><font color='#ff9933'><b>[ceil(fire_loss)]</b></font></td>\
							<td><font color='#00cc66'><b>[ceil(tox_loss)]</b></font></td>\
							<td><font color='#33ccff'><b>[ceil(oxy_loss)]</b></font></td>\
							</tr>"

			if(mode == SCANNER_VERBOSE)
				// Follow same body zone list every time so it's consistent across all humans
				for(var/zone in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
					var/obj/item/bodypart/limb = carbontarget.get_bodypart(zone)
					if(isnull(limb))
						dmgreport += "<tr>"
						dmgreport += "<td><font color='#cc3333'>[capitalize(parse_zone(zone))]:</font></td>"
						dmgreport += "<td><font color='#cc3333'>-</font></td>"
						dmgreport += "<td><font color='#ff9933'>-</font></td>"
						dmgreport += "</tr>"
						dmgreport += "<tr><td colspan=6><span class='alert ml-2'>&rdsh; Physical trauma: [conditional_tooltip("Dismembered", "Reattach or replace surgically.", tochat)]</span></td></tr>"
						continue
					var/has_any_embeds = length(limb.embedded_objects) >= 1
					var/has_any_wounds = length(limb.wounds) >= 1
					var/is_damaged = limb.burn_dam > 0 || limb.brute_dam > 0
					if(!is_damaged && (zone != BODY_ZONE_CHEST || (tox_loss <= 0 && oxy_loss <= 0)) && !has_any_embeds && !has_any_wounds)
						continue
					dmgreport += "<tr>"
					dmgreport += "<td><font color='#cc3333'>[capitalize((limb.bodytype & BODYTYPE_ROBOTIC) ? limb.name : limb.plaintext_zone)]:</font></td>"
					dmgreport += "<td><font color='#cc3333'>[limb.brute_dam > 0 ? ceil(limb.brute_dam) : "0"]</font></td>"
					dmgreport += "<td><font color='#ff9933'>[limb.burn_dam > 0 ? ceil(limb.burn_dam) : "0"]</font></td>"
					if(zone == BODY_ZONE_CHEST) // tox/oxy is stored in the chest
						dmgreport += "<td><font color='#00cc66'>[tox_loss > 0 ? ceil(tox_loss) : "0"]</font></td>"
						dmgreport += "<td><font color='#33ccff'>[oxy_loss > 0 ? ceil(oxy_loss) : "0"]</font></td>"
					dmgreport += "</tr>"
					if(has_any_embeds)
						var/list/embedded_names = list()
						for(var/obj/item/embed as anything in limb.embedded_objects)
							embedded_names[capitalize(embed.name)] += 1
						for(var/embedded_name in embedded_names)
							var/displayed = embedded_name
							var/embedded_amt = embedded_names[embedded_name]
							if(embedded_amt > 1)
								displayed = "[embedded_amt]x [embedded_name]"
							dmgreport += "<tr><td colspan=6><span class='alert ml-2'>&rdsh; Foreign object(s): [conditional_tooltip(displayed, "Use a hemostat to remove.", tochat)]</span></td></tr>"
					if(has_any_wounds)
						for(var/datum/wound/wound as anything in limb.wounds)
							dmgreport += "<tr><td colspan=6><span class='alert ml-2'>&rdsh; Physical trauma: [conditional_tooltip("[wound.name] ([wound.severity_text()])", wound.treat_text_short, tochat)]</span></td></tr>"

			dmgreport += "</table></font>"
			render_list += dmgreport // tables do not need extra linebreak

	if(ishuman(target))
		var/mob/living/carbon/human/humantarget = target

		// Organ damage, missing organs
		var/render = FALSE
		var/toReport = "<span class='info ml-1'>Organ status:</span>\
			<font face='Verdana'>\
			<table class='ml-2'>\
			<tr>\
			<td style='width:8em;'><font color='#ff0000'><b>Organ:</b></font></td>\
			[advanced ? "<td style='width:4em;'><font color='#ff0000'><b>Dmg</b></font></td>" : ""]\
			<td style='width:30em;'><font color='#ff0000'><b>Status</b></font></td>\
			</tr>"

		var/list/missing_organs = list()
		if(!humantarget.get_organ_slot(ORGAN_SLOT_BRAIN))
			missing_organs[ORGAN_SLOT_BRAIN] = "Brain"
		if(humantarget.needs_heart() && !humantarget.get_organ_slot(ORGAN_SLOT_HEART))
			missing_organs[ORGAN_SLOT_HEART] = "Heart"
		if(!HAS_TRAIT_FROM(humantarget, TRAIT_NOBREATH, SPECIES_TRAIT) && !isnull(humantarget.dna.species.mutantlungs) && !humantarget.get_organ_slot(ORGAN_SLOT_LUNGS))
			missing_organs[ORGAN_SLOT_LUNGS] = "Lungs"
		if(!HAS_TRAIT_FROM(humantarget, TRAIT_LIVERLESS_METABOLISM, SPECIES_TRAIT) && !isnull(humantarget.dna.species.mutantliver) && !humantarget.get_organ_slot(ORGAN_SLOT_LIVER))
			missing_organs[ORGAN_SLOT_LIVER] = "Liver"
		if(!HAS_TRAIT_FROM(humantarget, TRAIT_NOHUNGER, SPECIES_TRAIT) && !isnull(humantarget.dna.species.mutantstomach) && !humantarget.get_organ_slot(ORGAN_SLOT_STOMACH))
			missing_organs[ORGAN_SLOT_STOMACH] ="Stomach"
		if(!HAS_TRAIT_FROM(humantarget, TRAIT_SPLEENLESS_METABOLISM, SPECIES_TRAIT) && !isnull(humantarget.dna.species.mutantspleen) && !humantarget.get_organ_slot(ORGAN_SLOT_SPLEEN))
			missing_organs[ORGAN_SLOT_SPLEEN] ="Spleen"
		if(!isnull(humantarget.dna.species.mutanttongue) && !humantarget.get_organ_slot(ORGAN_SLOT_TONGUE))
			missing_organs[ORGAN_SLOT_TONGUE] = "Tongue"
		if(!isnull(humantarget.dna.species.mutantears) && !humantarget.get_organ_slot(ORGAN_SLOT_EARS))
			missing_organs[ORGAN_SLOT_EARS] = "Ears"
		if(!isnull(humantarget.dna.species.mutantears) && !humantarget.get_organ_slot(ORGAN_SLOT_EYES))
			missing_organs[ORGAN_SLOT_EYES] = "Eyes"

		// Follow same order as in the organ_process_order so it's consistent across all humans
		for(var/sorted_slot in GLOB.organ_process_order)
			var/obj/item/organ/organ = humantarget.get_organ_slot(sorted_slot)
			if(isnull(organ))
				if(missing_organs[sorted_slot])
					render = TRUE
					toReport += "<tr><td><font color='#cc3333'>[missing_organs[sorted_slot]]:</font></td>\
						[advanced ? "<td><font color='#ff3333'>-</font></td>" : ""]\
						<td><font color='#cc3333'>Missing</font></td></tr>"
				continue
			if(mode != SCANNER_VERBOSE && !organ.show_on_condensed_scans())
				continue
			var/status = organ.get_status_text(advanced, tochat)
			var/appendix = organ.get_status_appendix(advanced, tochat)
			if(status || appendix)
				status ||= "<font color='#ffcc33'>OK</font>" // otherwise flawless organs have no status reported by default
				render = TRUE
				toReport += "<tr>\
					<td><font color='#cc3333'>[capitalize(organ.name)]:</font></td>\
					[advanced ? "<td><font color='#ff3333'>[organ.damage > 0 ? ceil(organ.damage) : "0"]</font></td>" : ""]\
					<td>[status]</td>\
					</tr>"
				if(appendix)
					toReport += "<tr><td colspan=4><span class='alert ml-2'>&rdsh; [appendix]</span></td></tr>"

		if(render)
			render_list += "<hr>"
			render_list += toReport + "</table></font>" // tables do not need extra linebreak

		// Cybernetics
		var/list/cyberimps
		for(var/obj/item/organ/internal/cyberimp/cyberimp in humantarget.organs)
			if(IS_ROBOTIC_ORGAN(cyberimp) && !(cyberimp.organ_flags & ORGAN_HIDDEN))
				LAZYADD(cyberimps, cyberimp.get_examine_string(user))
		if(LAZYLEN(cyberimps))
			if(!render)
				render_list += "<hr>"
			render_list += "<span class='notice ml-1'>Detected cybernetic modifications:</span><br>"
			render_list += "<span class='notice ml-2'>[english_list(cyberimps, and_text = ", and ")]</span><br>"

		render_list += "<hr>"

		//Genetic stability
		if(advanced && humantarget.has_dna() && humantarget.dna.stability != initial(humantarget.dna.stability))
			render_list += "<span class='info ml-1'>Genetic Stability: [humantarget.dna.stability]%.</span>\n"

		// Species and body temperature
		var/datum/species/targetspecies = humantarget.dna.species
		var/mutant = humantarget.dna.check_mutation(/datum/mutation/hulk) \
			|| targetspecies.mutantlungs != initial(targetspecies.mutantlungs) \
			|| targetspecies.mutantbrain != initial(targetspecies.mutantbrain) \
			|| targetspecies.mutantheart != initial(targetspecies.mutantheart) \
			|| targetspecies.mutanteyes != initial(targetspecies.mutanteyes) \
			|| targetspecies.mutantears != initial(targetspecies.mutantears) \
			|| targetspecies.mutanttongue != initial(targetspecies.mutanttongue) \
			|| targetspecies.mutantliver != initial(targetspecies.mutantliver) \
			|| targetspecies.mutantstomach != initial(targetspecies.mutantstomach) \
			|| targetspecies.mutantspleen != initial(targetspecies.mutantspleen) \
			|| targetspecies.mutantappendix != initial(targetspecies.mutantappendix) \
			|| HAS_TRAIT(humantarget, TRAIT_HULK) \
			|| istype(humantarget.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS), /obj/item/organ/external/wings/functional)

		render_list += "<span class='info ml-1'>Species: [targetspecies.name][mutant ? "-derived mutant" : ""]</span>\n"
	var/skin_temp = target.get_skin_temperature()
	var/skin_temperature_message = "Skin temperature: [round(KELVIN_TO_CELCIUS(skin_temp), 0.1)] &deg;C ([round(KELVIN_TO_FAHRENHEIT(skin_temp), 0.1)] &deg;F)"
	if(skin_temp >= target.bodytemp_heat_damage_limit)
		render_list += "<span class='alert ml-1'>☼ [skin_temperature_message] ☼</span>\n"
	else if(skin_temp <= target.bodytemp_cold_damage_limit)
		render_list += "<span class='alert ml-1'>❄ [skin_temperature_message] ❄</span>\n"
	else
		render_list += "<span class='info ml-1'>[skin_temperature_message]</span>\n"

	var/body_temperature_message = "Body temperature: [round(KELVIN_TO_CELCIUS(target.bodytemperature), 0.1)] &deg;C ([round(KELVIN_TO_FAHRENHEIT(target.bodytemperature), 0.1)] &deg;F)"
	if(target.bodytemperature >= target.bodytemp_heat_damage_limit)
		render_list += "<span class='alert ml-1'>☼ [body_temperature_message] ☼</span>\n"
	else if(target.bodytemperature <= target.bodytemp_cold_damage_limit)
		render_list += "<span class='alert ml-1'>❄ [body_temperature_message] ❄</span>\n"
	else
		render_list += "<span class='info ml-1'>[body_temperature_message]</span>\n"

	// Blood Level
	// NON-MODULE CHANGE
	if(target.has_dna() && target.get_blood_type())
		if(iscarbon(target))
			var/mob/living/carbon/bleeder = target
			if(bleeder.is_bleeding())
				render_list += "<span class='alert ml-1'><b>Subject is bleeding!</b></span>\n"
		var/blood_percent = round((target.blood_volume / BLOOD_VOLUME_NORMAL) * 100)
		var/blood_type = "[target.get_blood_type() || "None"]"
		if(target.blood_volume <= BLOOD_VOLUME_SAFE && target.blood_volume > BLOOD_VOLUME_OKAY)
			render_list += "<span class='alert ml-1'>Blood level: LOW [blood_percent] %, [target.blood_volume] cl,</span> [span_info("type: [blood_type]")]\n"
		else if(target.blood_volume <= BLOOD_VOLUME_OKAY)
			render_list += "<span class='alert ml-1'>Blood level: <b>CRITICAL [blood_percent] %</b>, [target.blood_volume] cl,</span> [span_info("type: [blood_type]")]\n"
		else
			render_list += "<span class='info ml-1'>Blood level: [blood_percent] %, [target.blood_volume] cl, type: [blood_type]</span>\n"

	// Blood Alcohol Content
	var/blood_alcohol_content = target.get_blood_alcohol_content()
	var/datum/component/living_drunk/drinking_good = target.GetComponent(/datum/component/living_drunk)
	if(drinking_good)
		switch(drinking_good.drunk_state)
			if(3)
				render_list += "<span class='alert ml-1'><b>CRITICAL Extreme Alcohol withdrawal detected. Administer Ethanol related beverages immediately.</b></span><br>"
			if(2)
				render_list += "<span class='alert ml-1'>Dropping levels of Alcoholic byproducts. Consumption of Alcohol advised.</span><br>"
	if(blood_alcohol_content > 0)
		if(blood_alcohol_content >= 0.21 && isnull(drinking_good))
			render_list += "<span class='alert ml-1'>Blood alcohol content: <b>CRITICAL [blood_alcohol_content]%</b></span><br>"
		else
			render_list += "<span class='info ml-1'>Blood alcohol content: [blood_alcohol_content]%</span><br>"

	// Time of death
	if(target.tod && (target.stat == DEAD || (HAS_TRAIT(target, TRAIT_FAKEDEATH) && !advanced)))
		render_list += "<hr>"
		render_list += "<span class='info ml-1'>Time of Death: [target.tod]</span><br>"
		render_list += "<span class='alert ml-1'><b>Subject died [DisplayTimeText(round(world.time - target.timeofdeath))] ago.</b></span><br>"

	. = jointext(render_list, "")

	if(tochat)
		to_chat(user, boxed_message(.), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)
	return .

/proc/chemscan(mob/living/user, mob/living/target)
	if(user.incapacitated())
		return

	if(istype(target) && target.reagents)
		var/list/render_list = list() //The master list of readouts, including reagents in the blood/stomach, addictions, quirks, etc.
		var/list/render_block = list() //A second block of readout strings. If this ends up empty after checking stomach/blood contents, we give the "empty" header.

		// Blood reagents
		if(target.reagents.reagent_list.len)
			for(var/r in target.reagents.reagent_list)
				var/datum/reagent/reagent = r
				if(reagent.chemical_flags & REAGENT_INVISIBLE) //Don't show hidden chems on scanners
					continue
				render_block += "<span class='notice ml-2'>[round(reagent.volume, 0.001)] units of [reagent.name][reagent.overdosed ? "</span> - [span_boldannounce("OVERDOSING")]" : ".</span>"]\n"

		if(!length(render_block)) //If no VISIBLY DISPLAYED reagents are present, we report as if there is nothing.
			render_list += "<span class='notice ml-1'>Subject contains no reagents in their blood.</span>\n"
		else
			render_list += "<span class='notice ml-1'>Subject contains the following reagents in their blood:</span>\n"
			render_list += render_block //Otherwise, we add the header, reagent readouts, and clear the readout block for use on the stomach.
			render_block.Cut()

		// Stomach reagents
		var/obj/item/organ/internal/stomach/belly = target.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(belly)
			if(belly.reagents.reagent_list.len)
				for(var/bile in belly.reagents.reagent_list)
					var/datum/reagent/bit = bile
					if(bit.chemical_flags & REAGENT_INVISIBLE)
						continue
					if(!belly.food_reagents[bit.type])
						render_block += "<span class='notice ml-2'>[round(bit.volume, 0.001)] units of [bit.name][bit.overdosed ? "</span> - [span_boldannounce("OVERDOSING")]" : ".</span>"]\n"
					else
						var/bit_vol = bit.volume - belly.food_reagents[bit.type]
						if(bit_vol > 0)
							render_block += "<span class='notice ml-2'>[round(bit_vol, 0.001)] units of [bit.name][bit.overdosed ? "</span> - [span_boldannounce("OVERDOSING")]" : ".</span>"]\n"

			if(!length(render_block))
				render_list += "<span class='notice ml-1'>Subject contains no reagents in their stomach.</span>\n"
			else
				render_list += "<span class='notice ml-1'>Subject contains the following reagents in their stomach:</span>\n"
				render_list += render_block

		// Addictions
		if(LAZYLEN(target.mind?.active_addictions))
			render_list += "<span class='boldannounce ml-1'>Subject is addicted to the following types of drug:</span>\n"
			for(var/datum/addiction/addiction_type as anything in target.mind.active_addictions)
				render_list += "<span class='alert ml-2'>[initial(addiction_type.name)]</span>\n"

		// Special eigenstasium addiction
		if(target.has_status_effect(/datum/status_effect/eigenstasium))
			render_list += "<span class='notice ml-1'>Subject is temporally unstable. Stabilising agent is recommended to reduce disturbances.</span>\n"

		// Allergies
		for(var/datum/quirk/quirky as anything in target.quirks)
			if(istype(quirky, /datum/quirk/item_quirk/allergic))
				var/datum/quirk/item_quirk/allergic/allergies_quirk = quirky
				var/allergies = allergies_quirk.allergy_string
				render_list += "<span class='alert ml-1'>Subject is extremely allergic to the following chemicals:</span>\n"
				render_list += "<span class='alert ml-2'>[allergies]</span>\n"

		// we handled the last <br> so we don't need handholding
		to_chat(user, custom_boxed_message("blue_box", jointext(render_list, "")), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)

/obj/item/healthanalyzer/AltClick(mob/user)
	..()

	if(!user.can_perform_action(src, NEED_LITERACY|NEED_LIGHT) || user.is_blind())
		return

	if(mode == SCANNER_NO_MODE)
		return

	mode = !mode
	to_chat(user, mode == SCANNER_VERBOSE ? "The scanner now shows specific limb damage." : "The scanner no longer shows limb damage.")

/obj/item/healthanalyzer/advanced
	name = "advanced health analyzer"
	icon_state = "health_adv"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject with high accuracy."
	advanced = TRUE

#define AID_EMOTION_NEUTRAL "neutral"
#define AID_EMOTION_HAPPY "happy"
#define AID_EMOTION_WARN "cautious"
#define AID_EMOTION_ANGRY "angery"
#define AID_EMOTION_SAD "sad"

/// Displays wounds with extended information on their status vs medscanners
/proc/woundscan(mob/user, mob/living/carbon/patient, obj/item/healthanalyzer/scanner, simple_scan = FALSE)
	if(!istype(patient) || user.incapacitated())
		return

	var/render_list = ""
	var/advised = FALSE
	for(var/obj/item/bodypart/wounded_part as anything in patient.get_wounded_bodyparts())
		render_list += "<span class='alert ml-1'><b>Warning: Physical trauma[LAZYLEN(wounded_part.wounds) > 1? "s" : ""] detected in [wounded_part.plaintext_zone]</b>"
		for(var/datum/wound/current_wound as anything in wounded_part.wounds)
			render_list += "<div class='ml-2'>[simple_scan ? current_wound.get_simple_scanner_description() : current_wound.get_scanner_description()]</div>\n"
			if (scanner.give_wound_treatment_bonus)
				ADD_TRAIT(current_wound, TRAIT_WOUND_SCANNED, ANALYZER_TRAIT)
				if(!advised)
					to_chat(user, span_notice("You notice how bright holo-images appear over your [(length(wounded_part.wounds) || length(patient.get_wounded_bodyparts()) ) > 1 ? "various wounds" : "wound"]. They seem to be filled with helpful information, this should make treatment easier!"))
					advised = TRUE
		render_list += "</span>"

	if(render_list == "")
		if(simple_scan)
			var/obj/item/healthanalyzer/simple/simple_scanner = scanner
			// Only emit the cheerful scanner message if this scan came from a scanner
			playsound(simple_scanner, 'sound/machines/ping.ogg', 50, FALSE)
			to_chat(user, span_notice("\The [simple_scanner] makes a happy ping and briefly displays a smiley face with several exclamation points! It's really excited to report that [patient] has no wounds!"))
			simple_scanner.show_emotion(AID_EMOTION_HAPPY)
		to_chat(user, "<span class='notice ml-1'>No wounds detected in subject.</span>")
	else
		to_chat(user, custom_boxed_message("blue_box", jointext(render_list, "")), type = MESSAGE_TYPE_INFO)
		if(simple_scan)
			var/obj/item/healthanalyzer/simple/simple_scanner = scanner
			simple_scanner.show_emotion(AID_EMOTION_WARN)
			playsound(simple_scanner, 'sound/machines/twobeep.ogg', 50, FALSE)

//MONKESTATION ADDITION START
//Cyborgs can use an integrated health analyzer even if they cant see
/obj/item/healthanalyzer/cyborg

/obj/item/healthanalyzer/cyborg/attack_self(mob/user)
	if(!user.can_read(src, READING_CHECK_LITERACY))
		return

	scanmode = (scanmode + 1) % SCANMODE_COUNT
	switch(scanmode)
		if(SCANMODE_HEALTH)
			to_chat(user, span_notice("You switch the health analyzer to check physical health."))
		if(SCANMODE_WOUND)
			to_chat(user, span_notice("You switch the health analyzer to report extra info on wounds."))

/obj/item/healthanalyzer/cyborg/attack(mob/living/M, mob/living/carbon/human/user)
	if(!user.can_read(src, READING_CHECK_LITERACY))
		return

	flick("[icon_state]-scan", src) //makes it so that it plays the scan animation upon scanning, including clumsy scanning

	// Clumsiness/brain damage check
	if ((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
		user.visible_message(span_warning("[user] analyzes the floor's vitals!"), \
							span_notice("You stupidly try to analyze the floor's vitals!"))
		to_chat(user, "[span_info("Analyzing results for The floor:\n\tOverall status: <b>Healthy</b>")]\
				\n[span_info("Key: <font color='#00cccc'>Suffocation</font>/<font color='#00cc66'>Toxin</font>/<font color='#ffcc33'>Burn</font>/<font color='#ff3333'>Brute</font>")]\
				\n[span_info("\tDamage specifics: <font color='#66cccc'>0</font>-<font color='#00cc66'>0</font>-<font color='#ff9933'>0</font>-<font color='#ff3333'>0</font>")]\
				\n[span_info("Body temperature: ???")]")
		return

	if(ispodperson(M) && !advanced)
		to_chat(user, "<span class='info'>[M]'s biological structure is too complex for the health analyzer.")
		return

	user.visible_message(span_notice("[user] analyzes [M]'s vitals."))
	balloon_alert(user, "analyzing vitals")
	playsound(user.loc, 'sound/items/healthanalyzer.ogg', 50)

	switch (scanmode)
		if (SCANMODE_HEALTH)
			healthscan(user, M, mode, advanced)
		if (SCANMODE_WOUND)
			woundscan(user, M, src)

	add_fingerprint(user)

/obj/item/healthanalyzer/cyborg/attack_secondary(mob/living/victim, mob/living/user, params)
	if(!user.can_read(src, READING_CHECK_LITERACY))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	chemscan(user, victim)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
//MONKESTATION ADDITION END

/obj/item/healthanalyzer/simple
	name = "wound analyzer"
	icon_state = "first_aid"
	desc = "A helpful, child-proofed, and most importantly, extremely cheap MeLo-Tech medical scanner used to diagnose injuries and recommend treatment for serious wounds. While it might not sound very informative for it to be able to tell you if you have a gaping hole in your body or not, it applies a temporary holoimage near the wound with information that is guaranteed to double the efficacy and speed of treatment."
	mode = SCANNER_NO_MODE
	// Cooldown for when the analyzer will allow you to ask it for encouragement. Don't get greedy!
	var/next_encouragement
	// The analyzer's current emotion. Affects the sprite overlays and if it's going to prick you for being greedy or not.
	var/emotion = AID_EMOTION_NEUTRAL
	// Encouragements to play when attack_selfing
	var/list/encouragements = list("briefly displays a happy face, gazing emptily at you", "briefly displays a spinning cartoon heart", "displays an encouraging message about eating healthy and exercising", \
			"reminds you that everyone is doing their best", "displays a message wishing you well", "displays a sincere thank-you for your interest in first-aid", "formally absolves you of all your sins")
	// How often one can ask for encouragement
	var/patience = 10 SECONDS
	give_wound_treatment_bonus = TRUE

/obj/item/healthanalyzer/simple/attack_self(mob/user)
	if(next_encouragement < world.time)
		playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
		to_chat(user, span_notice("\The [src] makes a happy ping and [pick(encouragements)]!"))
		next_encouragement = world.time + 10 SECONDS
		show_emotion(AID_EMOTION_HAPPY)
	else if(emotion != AID_EMOTION_ANGRY)
		greed_warning(user)
	else
		violence(user)

/obj/item/healthanalyzer/simple/proc/greed_warning(mob/user)
	to_chat(user, span_warning("\The [src] displays an eerily high-definition frowny face, chastizing you for asking it for too much encouragement."))
	show_emotion(AID_EMOTION_ANGRY)

/obj/item/healthanalyzer/simple/proc/violence(mob/user)
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
	if(isliving(user))
		var/mob/living/L = user
		to_chat(L, span_warning("\The [src] makes a disappointed buzz and pricks your finger for being greedy. Ow!"))
		flick(icon_state + "_pinprick", src)
		L.adjustBruteLoss(4)
		L.dropItemToGround(src)
		show_emotion(AID_EMOTION_HAPPY)

/obj/item/healthanalyzer/simple/attack(mob/living/carbon/patient, mob/living/carbon/human/user)
	if(!user.can_read(src) || user.is_blind())
		return

	add_fingerprint(user)
	user.visible_message(span_notice("[user] scans [patient] for serious injuries."), span_notice("You scan [patient] for serious injuries."))

	if(!istype(patient))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		to_chat(user, span_warning("\The [src] makes a sad buzz and briefly displays an unhappy face, indicating it can't scan [patient]."))
		show_emotion(AI_EMOTION_SAD)
		return

	woundscan(user, patient, src, simple_scan = TRUE)
	flick(icon_state + "_pinprick", src)

/obj/item/healthanalyzer/simple/update_overlays()
	. = ..()
	switch(emotion)
		if(AID_EMOTION_HAPPY)
			. += mutable_appearance(icon, "+no_wounds")
		if(AID_EMOTION_WARN)
			. += mutable_appearance(icon, "+wound_warn")
		if(AID_EMOTION_ANGRY)
			. += mutable_appearance(icon, "+angry")
		if(AID_EMOTION_SAD)
			. += mutable_appearance(icon, "+fail_scan")

/// Sets a new emotion display on the scanner, and resets back to neutral in a moment
/obj/item/healthanalyzer/simple/proc/show_emotion(new_emotion)
	emotion = new_emotion
	update_appearance(UPDATE_OVERLAYS)
	if (emotion != AID_EMOTION_NEUTRAL)
		addtimer(CALLBACK(src, PROC_REF(reset_emotions), AID_EMOTION_NEUTRAL), 2 SECONDS)

// Resets visible emotion back to neutral
/obj/item/healthanalyzer/simple/proc/reset_emotions()
	emotion = AID_EMOTION_NEUTRAL
	update_appearance(UPDATE_OVERLAYS)

/obj/item/healthanalyzer/simple/miner
	name = "mining wound analyzer"
	icon_state = "miner_aid"
	desc = "A helpful, child-proofed, and most importantly, extremely cheap MeLo-Tech medical scanner used to diagnose injuries and recommend treatment for serious wounds. While it might not sound very informative for it to be able to tell you if you have a gaping hole in your body or not, it applies a temporary holoimage near the wound with information that is guaranteed to double the efficacy and speed of treatment. This one has a cool aesthetic antenna that doesn't actually do anything!"

/obj/item/healthanalyzer/simple/disease
	name = "disease state analyzer"
	desc = "Another of MeLo-Tech's dubiously useful medsci scanners, the disease analyzer is a pretty rare find these days - NT found out that giving their hospitals the lowest-common-denominator pandemic equipment resulted in too much financial loss of life to be profitable. There's rumours that the inbuilt AI is jealous of the first aid analyzer's success."
	icon_state = "disease_aid"
	mode = SCANNER_NO_MODE
	encouragements = list("encourages you to take your medication", "briefly displays a spinning cartoon heart", "reasures you about your condition", \
			"reminds you that everyone is doing their best", "displays a message wishing you well", "displays a message saying how proud it is that you're taking care of yourself", "formally absolves you of all your sins")
	patience = 20 SECONDS

/obj/item/healthanalyzer/simple/disease/greed_warning(mob/user)
	to_chat(user, span_warning("\The [src] displays an eerily high-definition frowny face, chastizing you for asking it for too much encouragement."))
	show_emotion(AID_EMOTION_ANGRY)

/obj/item/healthanalyzer/simple/disease/violence(mob/user)
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
	if(isliving(user))
		var/mob/living/L = user
		to_chat(L, span_warning("\The [src] makes a disappointed buzz and pricks your finger for being greedy. Ow!"))
		flick(icon_state + "_pinprick", src)
		L.adjustBruteLoss(1)
		L.reagents.add_reagent(/datum/reagent/toxin, rand(1, 3))
		L.dropItemToGround(src)
		show_emotion(AID_EMOTION_ANGRY)

/obj/item/healthanalyzer/simple/disease/attack(mob/living/carbon/patient, mob/living/carbon/human/user)
	if(!user.can_read(src) || user.is_blind())
		return

	add_fingerprint(user)
	user.visible_message(span_notice("[user] scans [patient] for diseases."), span_notice("You scan [patient] for diseases."))

	if(!istype(patient))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		to_chat(user, span_warning("\The [src] makes a sad buzz and briefly displays a frowny face, indicating it can't scan [patient]."))
		emotion = AID_EMOTION_SAD
		update_appearance(UPDATE_OVERLAYS)
		return

	diseasescan(user, patient, src) // this updates emotion
	update_appearance(UPDATE_OVERLAYS)
	flick(icon_state + "_pinprick", src)

/obj/item/healthanalyzer/simple/disease/update_overlays()
	. = ..()
	switch(emotion)
		if(AID_EMOTION_HAPPY)
			. += mutable_appearance(icon, "+not_infected")
		if(AID_EMOTION_WARN)
			. += mutable_appearance(icon, "+infected")
		if(AID_EMOTION_ANGRY)
			. += mutable_appearance(icon, "+rancurous")
		if(AID_EMOTION_SAD)
			. += mutable_appearance(icon, "+unknown_scan")
	if(emotion != AID_EMOTION_NEUTRAL)
		addtimer(CALLBACK(src, PROC_REF(reset_emotions)), 4 SECONDS) // longer on purpose

//Checks the individual for any diseases that are visible to the scanner, and displays the diseases in the attacked to the attacker.
/proc/diseasescan(mob/user, mob/living/carbon/patient, obj/item/healthanalyzer/simple/scanner)
	if(!istype(patient) || user.incapacitated())
		return

	var/list/render = list()
	for(var/datum/disease/disease as anything in patient.diseases)
		if(istype(disease, /datum/disease/acute))
			var/datum/disease/acute/advanced = disease
			advanced.Refresh_Acute()
			if(!(disease.visibility_flags & HIDDEN_SCANNER))
				render += "<span class='alert ml-1'><b>Warning: [advanced.origin] disease detected</b>\n\
				<div class='ml-2'>Name: [advanced.real_name()].\nType: [disease.get_spread_string()].\nStage: [disease.stage]/[disease.max_stages].</div>\
				</span>"

		else
			if(!(disease.visibility_flags & HIDDEN_SCANNER))
				render += "<span class='alert ml-1'><b>Warning: [disease.form] disease detected</b>\n\
				<div class='ml-2'>Name: [disease.name].\nType: [disease.get_spread_string()].\nStage: [disease.stage]/[disease.max_stages].\nPossible Cure: [disease.cure_text]</div>\
				</span>"

	if(!length(render))
		playsound(scanner, 'sound/machines/ping.ogg', 50, FALSE)
		to_chat(user, span_notice("\The [scanner] makes a happy ping and briefly displays a smiley face with several exclamation points! It's really excited to report that [patient] has no diseases!"))
		scanner.emotion = AID_EMOTION_HAPPY
	else
		to_chat(user, span_notice(render.Join("")))
		scanner.emotion = AID_EMOTION_WARN
		playsound(scanner, 'sound/machines/twobeep.ogg', 50, FALSE)

#undef SCANMODE_HEALTH
#undef SCANMODE_WOUND
#undef SCANMODE_COUNT
#undef SCANNER_CONDENSED
#undef SCANNER_VERBOSE
#undef SCANNER_NO_MODE

#undef AID_EMOTION_NEUTRAL
#undef AID_EMOTION_HAPPY
#undef AID_EMOTION_WARN
#undef AID_EMOTION_ANGRY
#undef AID_EMOTION_SAD

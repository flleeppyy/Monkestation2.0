//- Are all the floors with or without air, as they should be? (regular or airless)
//- Does the area have an APC?
//- Does the area have an Air Alarm?
//- Does the area have a Request Console?
//- Does the area have lights?
//- Does the area have a light switch?
//- Does the area have enough intercoms?
//- Does the area have enough security cameras? (Use the 'Camera Range Display' verb under Debug)
//- Is the area connected to the scrubbers air loop?
//- Is the area connected to the vent air loop? (vent pumps)
//- Is everything wired properly?
//- Does the area have a fire alarm and firedoors?
//- Do all pod doors work properly?
//- Are accesses set properly on doors, pod buttons, etc.
//- Are all items placed properly? (not below vents, scrubbers, tables)
//- Does the disposal system work properly from all the disposal units in this room and all the units, the pipes of which pass through this room?
//- Check for any misplaced or stacked piece of pipe (air and disposal)
//- Check for any misplaced or stacked piece of wire
//- Identify how hard it is to break into the area and where the weak points are
//- Check if the area has too much empty space. If so, make it smaller and replace the rest with maintenance tunnels.

GLOBAL_LIST_INIT(admin_verbs_debug_mapping, list(
	/client/proc/camera_view, //-errorage
	/client/proc/sec_camera_report, //-errorage
	/client/proc/intercom_view, //-errorage
	/client/proc/air_status, //Air things
	/client/proc/Cell, //More air things
	/client/proc/atmosscan, //check plumbing
	/client/proc/powerdebug, //check power
	/client/proc/count_objects_on_z_level,
	/client/proc/count_objects_all,
	/client/proc/cmd_assume_direct_control, //-errorage
	/client/proc/cmd_give_direct_control,
	/client/proc/set_server_fps, //allows you to set the ticklag.
	/client/proc/cmd_admin_grantfullaccess,
	/client/proc/cmd_admin_areatest_all,
	/client/proc/cmd_admin_areatest_station,
	/client/proc/cmd_admin_areatest_station_no_maintenance,
	#ifdef TESTING
	/client/proc/see_dirty_varedits,
	#endif
	/client/proc/cmd_admin_rejuvenate,
	/datum/admins/proc/show_traitor_panel,
	/client/proc/disable_communication,
	/client/proc/show_map_reports,
	/client/proc/cmd_show_at_list,
	/client/proc/cmd_show_at_markers,
	/client/proc/manipulate_organs,
	/client/proc/start_line_profiling,
	/client/proc/stop_line_profiling,
	/client/proc/show_line_profiling,
	/client/proc/create_mapping_job_icons,
	/client/proc/debug_z_levels,
	/client/proc/place_ruin,
	/client/proc/station_food_debug,
	/client/proc/station_stack_debug,
	/client/proc/check_for_obstructed_atmospherics,
	/client/proc/export_lighting_info, // monkestation addition
))
GLOBAL_PROTECT(admin_verbs_debug_mapping)

/client/proc/camera_view()
	set category = "Mapping"
	set name = "Camera Range Display"

	var/on = FALSE
	for(var/turf/T in world)
		if(T.maptext)
			on = TRUE
		T.maptext = null

	if(!on)
		var/list/seen = list()
		for(var/obj/machinery/camera/C as anything in GLOB.cameranet.cameras)
			for(var/turf/T in C.can_see())
				seen[T]++
		for(var/turf/T in seen)
			T.maptext = MAPTEXT(seen[T])
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Camera Range") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Camera Range")

#ifdef TESTING
GLOBAL_LIST_EMPTY(dirty_vars)

/client/proc/see_dirty_varedits()
	set category = "Mapping"
	set name = "Dirty Varedits"

	var/list/dat = list()
	dat += "<h3>Abandon all hope ye who enter here</h3><br><br>"
	for(var/thing in GLOB.dirty_vars)
		dat += "[thing]<br>"
		CHECK_TICK
	var/datum/browser/popup = new(usr, "dirty_vars", "Dirty Varedits", 900, 750)
	popup.set_content(dat.Join())
	popup.open()
#endif

/client/proc/sec_camera_report()
	set category = "Mapping"
	set name = "Camera Report"

	if(!Master)
		tgui_alert(usr,"Master_controller not found.","Sec Camera Report")
		return FALSE

	var/list/obj/machinery/camera/CL = list()

	for(var/obj/machinery/camera/C as anything in GLOB.cameranet.cameras)
		CL += C

	var/output = {"<B>Camera Abnormalities Report</B><HR>
<B>The following abnormalities have been detected. The ones in red need immediate attention: Some of those in black may be intentional.</B><BR><ul>"}

	for(var/obj/machinery/camera/C1 in CL)
		for(var/obj/machinery/camera/C2 in CL)
			if(C1 != C2)
				if(C1.c_tag == C2.c_tag)
					output += "<li><font color='red'>c_tag match for cameras at [ADMIN_VERBOSEJMP(C1)] and [ADMIN_VERBOSEJMP(C2)] - c_tag is [C1.c_tag]</font></li>"
				if(C1.loc == C2.loc && C1.dir == C2.dir && C1.pixel_x == C2.pixel_x && C1.pixel_y == C2.pixel_y)
					output += "<li><font color='red'>FULLY overlapping cameras at [ADMIN_VERBOSEJMP(C1)] Networks: [json_encode(C1.network)] and [json_encode(C2.network)]</font></li>"
				if(C1.loc == C2.loc)
					output += "<li>Overlapping cameras at [ADMIN_VERBOSEJMP(C1)] Networks: [json_encode(C1.network)] and [json_encode(C2.network)]</li>"
		var/turf/T = get_step(C1,C1.dir)
		if(!T || !isturf(T) || !T.density )
			if(!(locate(/obj/structure/grille) in T))
				var/window_check = 0
				for(var/obj/structure/window/W in T)
					if (W.dir == turn(C1.dir,180) || (W.dir in list(NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST)) )
						window_check = 1
						break
				if(!window_check)
					output += "<li><font color='red'>Camera not connected to wall at [ADMIN_VERBOSEJMP(C1)] Network: [json_encode(C1.network)]</font></li>"

	output += "</ul>"
	usr << browse(output,"window=airreport;size=1000x500")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Camera Report") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/intercom_view()
	set category = "Mapping"
	set name = "Intercom Range Display"

	var/static/intercom_range_display_status = FALSE
	intercom_range_display_status = !intercom_range_display_status //blame cyberboss if this breaks something //blamed

	for(var/obj/effect/abstract/marker/intercom/marker in GLOB.all_abstract_markers)
		qdel(marker)

	if(intercom_range_display_status)
		for(var/frequency in GLOB.all_radios)
			for(var/obj/item/radio/intercom/intercom in GLOB.all_radios[frequency])
				for(var/turf/turf in view(7,intercom.loc))
					new /obj/effect/abstract/marker/intercom(turf)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Intercom Range") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/show_map_reports()
	set category = "Mapping"
	set name = "Show map report list"
	set desc = "Displays a list of map reports"

	var/dat = {"<b>List of all map reports:</b><br>"}

	for(var/datum/map_report/report as anything in GLOB.map_reports)
		dat += "[report.tag] ([report.original_path]) - <a href='byond://?src=[REF(report)];[HrefToken()];show=1'>View</a><br>"

	usr << browse(HTML_SKELETON(dat), "window=map_reports")

/client/proc/cmd_show_at_list()
	set category = "Mapping"
	set name = "Show roundstart AT list"
	set desc = "Displays a list of active turfs coordinates at roundstart"

	var/dat = {"<b>Coordinate list of Active Turfs at Roundstart</b>
		<br>Real-time Active Turfs list you can see in Air Subsystem at active_turfs var<br>"}

	for(var/t in GLOB.active_turfs_startlist)
		var/turf/T = t
		dat += "[ADMIN_VERBOSEJMP(T)]\n"
		dat += "<br>"

	usr << browse(HTML_SKELETON(dat), "window=at_list")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Roundstart Active Turfs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_show_at_markers()
	set category = "Mapping"
	set name = "Show roundstart AT markers"
	set desc = "Places a marker on all active-at-roundstart turfs"

	var/count = 0
	for(var/obj/effect/abstract/marker/at/AT in GLOB.all_abstract_markers)
		qdel(AT)
		count++

	if(count)
		to_chat(usr, "[count] AT markers removed.", confidential = TRUE)
	else
		for(var/t in GLOB.active_turfs_startlist)
			new /obj/effect/abstract/marker/at(t)
			count++
		to_chat(usr, "[count] AT markers placed.", confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Roundstart Active Turf Markers")

/client/proc/enable_mapping_verbs()
	set category = "Debug"
	set name = "Mapping verbs - Enable"
	if(!check_rights(R_DEBUG))
		return
	remove_verb(src, /client/proc/enable_mapping_verbs)
	add_verb(src, list(/client/proc/disable_mapping_verbs, GLOB.admin_verbs_debug_mapping))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Enable Debug Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/disable_mapping_verbs()
	set category = "Debug"
	set name = "Mapping verbs - Disable"
	remove_verb(src, list(/client/proc/disable_mapping_verbs, GLOB.admin_verbs_debug_mapping))
	add_verb(src, /client/proc/enable_mapping_verbs)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Disable Debug Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/count_objects_on_z_level()
	set category = "Mapping"
	set name = "Count Objects On Level"
	var/level = input("Which z-level?","Level?") as text|null
	if(!level)
		return
	var/num_level = text2num(level)
	if(!num_level)
		return
	if(!isnum(num_level))
		return

	var/type_text = input("Which type path?","Path?") as text|null
	if(!type_text)
		return
	var/type_path = text2path(type_text)
	if(!type_path)
		return

	var/count = 0

	var/list/atom/atom_list = list()

	for(var/atom/A in world)
		if(istype(A,type_path))
			var/atom/B = A
			while(!(isturf(B.loc)))
				if(B?.loc)
					B = B.loc
				else
					break
			if(B)
				if(B.z == num_level)
					count++
					atom_list += A

	to_chat(world, "There are [count] objects of type [type_path] on z-level [num_level]", confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Count Objects Zlevel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/count_objects_all()
	set category = "Mapping"
	set name = "Count Objects All"

	var/type_text = input("Which type path?","") as text|null
	if(!type_text)
		return
	var/type_path = text2path(type_text)
	if(!type_path)
		return

	var/count = 0

	for(var/atom/A in world)
		if(istype(A,type_path))
			count++

	to_chat(world, "There are [count] objects of type [type_path] in the game world", confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Count Objects All") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//This proc is intended to detect lag problems relating to communication procs
GLOBAL_VAR_INIT(say_disabled, FALSE)
/client/proc/disable_communication()
	set category = "Mapping"
	set name = "Disable all communication verbs"

	GLOB.say_disabled = !GLOB.say_disabled
	if(GLOB.say_disabled)
		message_admins("[key] used 'Disable all communication verbs', killing all communication methods.")
	else
		message_admins("[key] used 'Disable all communication verbs', restoring all communication methods.")

//This generates the icon states for job starting location landmarks.
/client/proc/create_mapping_job_icons()
	set name = "Generate job landmarks icons"
	set category = "Mapping"
	var/icon/final = icon()
	var/mob/living/carbon/human/dummy/D = new(locate(1,1,1)) //spawn on 1,1,1 so we don't have runtimes when items are deleted
	D.setDir(SOUTH)
	for(var/job in subtypesof(/datum/job))
		var/datum/job/JB = new job
		switch(JB.title)
			if(JOB_AI)
				final.Insert(icon('icons/mob/silicon/ai.dmi', "ai", SOUTH, 1), "AI")
			if(JOB_CYBORG)
				final.Insert(icon('icons/mob/silicon/robots.dmi', "robot", SOUTH, 1), "Cyborg")
			else
				for(var/obj/item/I in D)
					qdel(I)
				randomize_human(D)
				D.dress_up_as_job(JB, TRUE)
				var/icon/I = icon(getFlatIcon(D), frame = 1)
				final.Insert(I, JB.title)
	qdel(D)
	//Also add the x
	for(var/x_number in 1 to 4)
		final.Insert(icon('icons/hud/screen_gen.dmi', "x[x_number == 1 ? "" : x_number]"), "x[x_number == 1 ? "" : x_number]")
	fcopy(final, "icons/mob/landmarks.dmi")

/client/proc/debug_z_levels()
	set name = "Debug Z-Levels"
	set category = "Mapping"

	var/list/z_list = SSmapping.z_list
	var/list/messages = list()
	messages += "<b>World</b>: [world.maxx] x [world.maxy] x [world.maxz]<br><br>"

	var/list/linked_levels = list()
	var/min_x = INFINITY
	var/min_y = INFINITY
	var/max_x = -INFINITY
	var/max_y = -INFINITY

	for(var/z in 1 to max(world.maxz, z_list.len))
		if (z > z_list.len)
			messages += "<b>[z]</b>: Unmanaged (out of bounds)<br>"
			continue
		var/datum/space_level/S = z_list[z]
		if (!S)
			messages += "<b>[z]</b>: Unmanaged (null)<br>"
			continue
		var/linkage
		switch (S.linkage)
			if (UNAFFECTED)
				linkage = "no linkage"
			if (SELFLOOPING)
				linkage = "self-looping"
			if (CROSSLINKED)
				linkage = "linked at ([S.xi], [S.yi])"
				linked_levels += S
				min_x = min(min_x, S.xi)
				min_y = min(min_y, S.yi)
				max_x = max(max_x, S.xi)
				max_y = max(max_y, S.yi)
			else
				linkage = "unknown linkage '[S.linkage]'"

		messages += "<b>[z]</b>: [S.name], [linkage], traits: [json_encode(S.traits)]<br>"
		if (S.z_value != z)
			messages += "-- z_value is [S.z_value], should be [z]<br>"
		if (S.name == initial(S.name))
			messages += "-- name not set<br>"
		if (z > world.maxz)
			messages += "-- exceeds max z"

	var/grid[max_x - min_x + 1][max_y - min_y + 1]
	for(var/datum/space_level/S in linked_levels)
		grid[S.xi - min_x + 1][S.yi - min_y + 1] = S.z_value

	messages += "<br><table border='1'>"
	for(var/y in max_y to min_y step -1)
		var/list/part = list()
		for(var/x in min_x to max_x)
			part += "[grid[x - min_x + 1][y - min_y + 1]]"
		messages += "<tr><td>[part.Join("</td><td>")]</td></tr>"
	messages += "</table>"

	to_chat(src, boxed_message(messages.Join("")), confidential = TRUE)

/client/proc/station_food_debug()
	set name = "Count Station Food"
	set category = "Mapping"
	var/list/foodcount = list()
	for(var/obj/item/food/fuck_me in world)
		var/turf/location = get_turf(fuck_me)
		if(!location || SSmapping.level_trait(location.z, ZTRAIT_STATION))
			continue
		LAZYADDASSOC(foodcount, fuck_me.type, 1)

	var/table_header = "<tr><th>Name</th> <th>Type</th> <th>Amount</th>"
	var/table_contents = list()
	for(var/atom/type as anything in foodcount)
		var/foodname = initial(type.name)
		var/count = foodcount[type]
		table_contents += "<tr><td>[foodname]</td> <td>[type]</td> <td>[count]</td></tr>"

	var/page_style = "<style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style>"
	var/page_contents = "[page_style]<table style=\"width:100%\">[table_header][jointext(table_contents, "")]</table>"
	var/datum/browser/popup = new(mob, "fooddebug", "Station Food Count", 600, 400)
	popup.set_content(page_contents)
	popup.open()

/client/proc/station_stack_debug()
	set name = "Count Station Stacks"
	set category = "Mapping"
	var/list/stackcount = list()
	for(var/obj/item/stack/fuck_me in world)
		var/turf/location = get_turf(fuck_me)
		if(!location || SSmapping.level_trait(location.z, ZTRAIT_STATION))
			continue
		LAZYADDASSOC(stackcount, fuck_me.type, fuck_me.amount)

	var/table_header = "<tr><th>Name</th> <th>Type</th> <th>Amount</th>"
	var/table_contents = list()
	for(var/atom/type as anything in stackcount)
		var/stackname = initial(type.name)
		var/count = stackcount[type]
		table_contents += "<tr><td>[stackname]</td> <td>[type]</td> <td>[count]</td></tr>"

	var/page_style = "<style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style>"
	var/page_contents = "[page_style]<table style=\"width:100%\">[table_header][jointext(table_contents, "")]</table>"
	var/datum/browser/popup = new(mob, "stackdebug", "Station Stack Count", 600, 400)
	popup.set_content(page_contents)
	popup.open()

/// Check all tiles with a vent or scrubber on it and ensure that nothing is covering it up.
/client/proc/check_for_obstructed_atmospherics()
	set name = "Check For Obstructed Atmospherics"
	set category = "Mapping"
	if(!holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return
	message_admins(span_adminnotice("[key_name_admin(usr)] is checking for obstructed atmospherics through the debug command."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check For Obstructed Atmospherics") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	var/list/results = list()

	results += "<h2><b>Anything that is considered to aesthetically obstruct an atmospherics machine (vent, scrubber, port) is listed below.</b> Please re-arrange to accomodate for this.</h2><br>"

	// Ignore out stuff we see in normal and standard mapping that we don't care about (false alarms). Typically stuff that goes directionally off turfs or other undertile objects that we don't want to care about.
	var/list/ignore_list = list(
		/obj/effect,
		/obj/item/shard, // it's benign enough to where we don't need to error, yet common enough to filter. fuck.
		/obj/machinery/airalarm,
		/obj/machinery/atmospherics/components/unary, //don't wanna flag on the vent or scrubber itself.
		/obj/machinery/atmospherics/pipe,
		/obj/machinery/button,
		/obj/machinery/camera,
		/obj/machinery/door_buttons,
		/obj/machinery/door/window, // i kind of wish we didn't have to do it but we have some particularly compact areas that we need to be wary of
		/obj/machinery/duct,
		/obj/machinery/firealarm,
		/obj/machinery/flasher,
		/obj/machinery/light_switch,
		/obj/machinery/light,
		/obj/machinery/navbeacon,
		/obj/machinery/newscaster,
		/obj/machinery/portable_atmospherics,
		/obj/machinery/power/apc,
		/obj/machinery/power/terminal,
		/obj/machinery/sparker,
		/obj/machinery/status_display,
		/obj/machinery/turretid,
		/obj/structure/cable,
		/obj/structure/disposalpipe,
		/obj/structure/extinguisher_cabinet,
		/obj/structure/lattice,
		/obj/structure/sign,
		/obj/structure/urinal, // the reason why this one gets to live and not the shower/sink is because it's pretty firmly on a wall.
		/obj/structure/window/reinforced,
	)

	for(var/turf/iterated_turf in world)
		var/obj/machinery/atmospherics/components/unary/device = locate() in iterated_turf.contents
		if(!device)
			continue
		var/list/obj/obstruction = locate(/obj) in iterated_turf.contents
		if(!is_type_in_list(obstruction, ignore_list))
			results += "There is an obstruction on top of an atmospherics machine at: [ADMIN_VERBOSEJMP(iterated_turf)].<br>"

	if(results.len == 1) // only the header is in the list, we're good
		to_chat(src, "No obstructions detected.", confidential = TRUE)
	else
		var/datum/browser/popup = new(usr, "atmospherics_obstructions", "Atmospherics Obstructions", 900, 750)
		popup.set_content(results.Join())
		popup.open()

SUBSYSTEM_DEF(atoms)
	name = "Atoms"
	init_order = INIT_ORDER_ATOMS
	flags = SS_NO_FIRE

	/// A stack of list(source, desired initialized state)
	/// We read the source of init changes from the last entry, and assert that all changes will come with a reset
	var/list/initialized_state = list()
	var/base_initialized

	var/list/late_loaders = list()

	var/list/BadInitializeCalls = list()

	///initAtom() adds the atom its creating to this list iff InitializeAtoms() has been given a list to populate as an argument
	var/list/created_atoms

	#ifdef PROFILE_MAPLOAD_INIT_ATOM
	var/list/init_costs = list()
	var/list/init_counts = list()

	var/list/late_init_costs = list()
	var/list/late_init_counts = list()
	#endif

	/// Atoms that will be deleted once the subsystem is initialized
	var/list/queued_deletions = list()

	var/init_start_time

	initialized = INITIALIZATION_INSSATOMS

/datum/controller/subsystem/atoms/Initialize()
	init_start_time = world.time
	setupGenetics() //to set the mutations' sequence

	initialized = INITIALIZATION_INNEW_MAPLOAD
	InitializeAtoms()
	initialized = INITIALIZATION_INNEW_REGULAR

	return SS_INIT_SUCCESS

/datum/controller/subsystem/atoms/proc/InitializeAtoms(list/atoms, list/atoms_to_return)
	if(initialized == INITIALIZATION_INSSATOMS)
		return

	// Generate a unique mapload source for this run of InitializeAtoms
	var/static/uid = 0
	uid = (uid + 1) % (SHORT_REAL_LIMIT - 1)
	var/source = "subsystem init [uid]"
	set_tracked_initalized(INITIALIZATION_INNEW_MAPLOAD, source)

	// This may look a bit odd, but if the actual atom creation runtimes for some reason, we absolutely need to set initialized BACK
	CreateAtoms(atoms, atoms_to_return, source)
	clear_tracked_initalize(source)
	SSicon_smooth.free_deferred(source)

	if(late_loaders.len)
		for(var/I in 1 to late_loaders.len)
			var/atom/A = late_loaders[I]
			//I hate that we need this
			if(QDELETED(A))
				continue

			#ifdef PROFILE_MAPLOAD_INIT_ATOM
			var/the_type = A.type
			late_init_costs |= the_type
			late_init_counts |= the_type
			var/startreal = REALTIMEOFDAY
			#endif

			A.LateInitialize()

			#ifdef PROFILE_MAPLOAD_INIT_ATOM
			late_init_costs[the_type] += REALTIMEOFDAY - startreal
			late_init_counts[the_type] += 1
			#endif

		testing("Late initialized [late_loaders.len] atoms")
		late_loaders.Cut()

	if (created_atoms)
		atoms_to_return += created_atoms
		created_atoms = null

	for (var/queued_deletion in queued_deletions)
		qdel(queued_deletion)

	testing("[queued_deletions.len] atoms were queued for deletion.")
	queued_deletions.Cut()

/// Actually creates the list of atoms. Exists soley so a runtime in the creation logic doesn't cause initalized to totally break
/datum/controller/subsystem/atoms/proc/CreateAtoms(list/atoms, list/atoms_to_return = null, mapload_source = null)
	if (atoms_to_return)
		LAZYINITLIST(created_atoms)

	#ifdef TESTING
	var/count
	#endif

	var/list/mapload_arg = list(TRUE)

	if(atoms)
		#ifdef TESTING
		count = atoms.len
		#endif

		for(var/I in 1 to atoms.len)
			var/atom/A = atoms[I]
			if(!(A.flags_1 & INITIALIZED_1))
				// Unrolled CHECK_TICK setup to let us enable/disable mapload based off source
				if(TICK_CHECK)
					clear_tracked_initalize(mapload_source)
					stoplag()
					if(mapload_source)
						set_tracked_initalized(INITIALIZATION_INNEW_MAPLOAD, mapload_source)
				InitAtom(A, TRUE, mapload_arg)
#ifndef DISABLE_DEMOS
		SSdemo.mark_multiple_new(atoms) // monkestation edit: replays
#endif
	else
		#ifdef TESTING
		count = 0
		#endif

		var/list/atoms_to_mark = list() // monkestation edit: replays
		for(var/atom/A as anything in world)
			if(!(A.flags_1 & INITIALIZED_1))
				InitAtom(A, FALSE, mapload_arg)
				atoms_to_mark += A // monkestation edit: replays
				#ifdef TESTING
				++count
				#endif
				if(TICK_CHECK)
					clear_tracked_initalize(mapload_source)
					stoplag()
					if(mapload_source)
						set_tracked_initalized(INITIALIZATION_INNEW_MAPLOAD, mapload_source)
#ifndef DISABLE_DEMOS
		SSdemo.mark_multiple_new(atoms_to_mark) // monkestation edit: replays
#endif

	testing("Initialized [count] atoms")

/// Init this specific atom
/datum/controller/subsystem/atoms/proc/InitAtom(atom/A, from_template = FALSE, list/arguments)
	var/the_type = A.type

	if(QDELING(A))
		// Check init_start_time to not worry about atoms created before the atoms SS that are cleaned up before this
		if (A.gc_destroyed > init_start_time)
			BadInitializeCalls[the_type] |= BAD_INIT_QDEL_BEFORE
		return TRUE

	#ifdef PROFILE_MAPLOAD_INIT_ATOM
	init_costs |= A.type
	init_counts |= A.type

	var/startreal = REALTIMEOFDAY
	#endif

	// This is handled and battle tested by dreamchecker. Limit to UNIT_TESTS just in case that ever fails.
	#ifdef UNIT_TESTS
	var/start_tick = world.time
	#endif

	var/result = A.Initialize(arglist(arguments))

	#ifdef UNIT_TESTS
	if(start_tick != world.time)
		BadInitializeCalls[the_type] |= BAD_INIT_SLEPT
	#endif

	var/qdeleted = FALSE

	switch(result)
		if (INITIALIZE_HINT_NORMAL)
			EMPTY_BLOCK_GUARD // Pass
		if(INITIALIZE_HINT_LATELOAD)
			if(arguments[1]) //mapload
				late_loaders += A
			else
				#ifdef PROFILE_MAPLOAD_INIT_ATOM
				late_init_costs |= the_type
				late_init_counts |= the_type
				var/late_startreal = REALTIMEOFDAY
				#endif
				A.LateInitialize(arguments)
				#ifdef PROFILE_MAPLOAD_INIT_ATOM
				late_init_costs[the_type] += REALTIMEOFDAY - late_startreal
				late_init_counts[the_type] += 1
				#endif
		if(INITIALIZE_HINT_QDEL)
			qdel(A)
			qdeleted = TRUE
		else
			BadInitializeCalls[the_type] |= BAD_INIT_NO_HINT

	if(!A) //possible harddel
		qdeleted = TRUE
	else if(!(A.flags_1 & INITIALIZED_1))
		BadInitializeCalls[the_type] |= BAD_INIT_DIDNT_INIT
	else
		SEND_SIGNAL(A, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ATOM_AFTER_POST_INIT, A)
		var/atom/location = A.loc
		if(location)
			/// Sends a signal that the new atom `src`, has been created at `loc`
			SEND_SIGNAL(location, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, A, arguments[1])
		if(created_atoms && from_template && ispath(the_type, /atom/movable))//we only want to populate the list with movables
			created_atoms += A.get_all_contents()

	#ifdef PROFILE_MAPLOAD_INIT_ATOM
	init_costs[A.type] += REALTIMEOFDAY - startreal
	init_counts[A.type] += 1
	#endif

	return qdeleted || QDELING(A)

/datum/controller/subsystem/atoms/proc/map_loader_begin(source)
	set_tracked_initalized(INITIALIZATION_INSSATOMS, source)

/datum/controller/subsystem/atoms/proc/map_loader_stop(source)
	clear_tracked_initalize(source)

/// Returns the source currently modifying SSatom's init behavior
/datum/controller/subsystem/atoms/proc/get_initialized_source()
	var/state_length = length(initialized_state)
	if(!state_length)
		return null
	return initialized_state[state_length][1]

/// Use this to set initialized to prevent error states where the old initialized is overriden, and we end up losing all context
/// Accepts a state and a source, the most recent state is used, sources exist to prevent overriding old values accidentially
/datum/controller/subsystem/atoms/proc/set_tracked_initalized(state, source)
	if(!length(initialized_state))
		base_initialized = initialized
	initialized_state += list(list(source, state))
	initialized = state

/datum/controller/subsystem/atoms/proc/clear_tracked_initalize(source)
	if(!length(initialized_state))
		return
	for(var/i in length(initialized_state) to 1 step -1)
		if(initialized_state[i][1] == source)
			initialized_state.Cut(i, i+1)
			break

	if(!length(initialized_state))
		initialized = base_initialized
		base_initialized = INITIALIZATION_INNEW_REGULAR
		return
	initialized = initialized_state[length(initialized_state)][2]

/// Returns TRUE if anything is currently being initialized
/datum/controller/subsystem/atoms/proc/initializing_something()
	return length(initialized_state) > 1

/datum/controller/subsystem/atoms/Recover()
	initialized = SSatoms.initialized
	if(initialized == INITIALIZATION_INNEW_MAPLOAD)
		InitializeAtoms()
	initialized_state = SSatoms.initialized_state
	BadInitializeCalls = SSatoms.BadInitializeCalls

/datum/controller/subsystem/atoms/proc/setupGenetics()
	var/list/mutations = subtypesof(/datum/mutation)
	shuffle_inplace(mutations)
	for(var/A in subtypesof(/datum/generecipe))
		var/datum/generecipe/GR = A
		GLOB.mutation_recipes[initial(GR.required)] = initial(GR.result)
	for(var/i in 1 to LAZYLEN(mutations))
		var/path = mutations[i] //byond gets pissy when we do it in one line
		var/datum/mutation/B = new path ()
		B.alias = "Mutation [i]"
		GLOB.all_mutations[B.type] = B
		GLOB.full_sequences[B.type] = generate_gene_sequence(B.blocks)
		GLOB.alias_mutations[B.alias] = B.type
		if(B.locked)
			continue
		if(B.quality == POSITIVE)
			GLOB.good_mutations |= B
		else if(B.quality == NEGATIVE)
			GLOB.bad_mutations |= B
		else if(B.quality == MINOR_NEGATIVE)
			GLOB.not_good_mutations |= B
		CHECK_TICK

/datum/controller/subsystem/atoms/proc/InitLog()
	. = ""
	for(var/path in BadInitializeCalls)
		. += "Path : [path] \n"
		var/fails = BadInitializeCalls[path]
		if(fails & BAD_INIT_DIDNT_INIT)
			. += "- Didn't call atom/Initialize(mapload)\n"
		if(fails & BAD_INIT_NO_HINT)
			. += "- Didn't return an Initialize hint\n"
		if(fails & BAD_INIT_QDEL_BEFORE)
			. += "- Qdel'd in New()\n"
		if(fails & BAD_INIT_SLEPT)
			. += "- Slept during Initialize()\n"

/// Prepares an atom to be deleted once the atoms SS is initialized.
/datum/controller/subsystem/atoms/proc/prepare_deletion(atom/target)
	if (initialized == INITIALIZATION_INNEW_REGULAR)
		// Atoms SS has already completed, just kill it now.
		qdel(target)
	else
		queued_deletions += WEAKREF(target)

/datum/controller/subsystem/atoms/Shutdown()
	var/initlog = InitLog()
	if(initlog)
		text2file(initlog, "[GLOB.log_directory]/initialize.log")

#ifdef PROFILE_MAPLOAD_INIT_ATOM
/datum/controller/subsystem/atoms/proc/InitCostLog(sort_by_avg = FALSE, show_late_init = FALSE)
	var/list/costs_to_use = show_late_init ? late_init_costs : init_costs
	var/list/counts_to_use = show_late_init ? late_init_counts : init_counts

	if(!LAZYLEN(costs_to_use))
		return "<div class='summary'><h2>No [show_late_init ? "Late " : ""]Initialization Data</h2></div>"

	var/list/cost_tree = list()
	var/total_cost = 0
	var/total_count = 0

	for(var/path in costs_to_use)
		var/cost = costs_to_use[path]
		var/count = counts_to_use[path]
		total_cost += cost
		total_count += count

		var/list/path_parts = splittext("[path]", "/")
		var/list/current_level = cost_tree
		var/built_path = ""

		for(var/i in 1 to path_parts.len)
			var/part = path_parts[i]
			if(!part) continue

			built_path += "[built_path ? "/" : ""][part]"

			if(!current_level[part])
				current_level[part] = list(
					"cost" = 0,
					"count" = 0,
					"direct_cost" = 0,
					"direct_count" = 0,
					"children" = list(),
					"path" = built_path,
					"is_leaf" = (i == path_parts.len)
				)

			if(i == path_parts.len)
				current_level[part]["direct_cost"] = cost
				current_level[part]["direct_count"] = count

			current_level[part]["cost"] += cost
			current_level[part]["count"] += count
			current_level = current_level[part]["children"]

	. = "<style>"
	. += "body { font-family: monospace; background: #1e1e1e; color: #d4d4d4; padding: 20px; }"
	. += ".tree-node { margin-left: 20px; margin-top: 5px; }"
	. += ".tree-item { cursor: pointer; padding: 3px 5px; border-radius: 3px; }"
	. += ".tree-item:hover { background: #2d2d30; }"
	. += ".cost-high { color: #f48771; font-weight: bold; }"
	. += ".cost-med { color: #dcdcaa; }"
	. += ".cost-low { color: #4ec9b0; }"
	. += ".expander { display: inline-block; width: 15px; }"
	. += ".percentage { color: #858585; font-size: 0.9em; }"
	. += ".count { color: #9cdcfe; font-size: 0.9em; }"
	. += ".avg { color: #ce9178; font-size: 0.9em; }"
	. += ".summary { background: #252526; padding: 15px; border-radius: 5px; margin-bottom: 20px; }"
	. += ".controls { background: #252526; padding: 10px; border-radius: 5px; margin-bottom: 15px; }"
	. += "button { background: #0e639c; color: white; border: none; padding: 8px 15px; border-radius: 3px; cursor: pointer; margin-right: 10px; }"
	. += "button:hover { background: #1177bb; }"
	. += "button.active { background: #1177bb; }"
	. += ".tab-group { display: inline-block; margin-right: 20px; }"
	. += "</style>"

	. += "<div class='controls'>"
	. += "<div class='tab-group'>"
	. += "<button class='[show_late_init ? "" : "active"]' onclick='window.location.href=\"byond://?src=[REF(src)];init_costs=1;sort=[sort_by_avg ? "avg" : "total"];mode=init\"'>Initialize()</button>"
	. += "<button class='[show_late_init ? "active" : ""]' onclick='window.location.href=\"byond://?src=[REF(src)];init_costs=1;sort=[sort_by_avg ? "avg" : "total"];mode=late\"'>LateInitialize()</button>"
	. += "</div>"
	. += "<div class='tab-group'>"
	. += "<button class='[sort_by_avg ? "" : "active"]' onclick='window.location.href=\"byond://?src=[REF(src)];init_costs=1;sort=total;mode=[show_late_init ? "late" : "init"]\"'>Sort by Total Time</button>"
	. += "<button class='[sort_by_avg ? "active" : ""]' onclick='window.location.href=\"byond://?src=[REF(src)];init_costs=1;sort=avg;mode=[show_late_init ? "late" : "init"]\"'>Sort by Average Time</button>"
	. += "</div>"
	. += "</div>"

	. += "<div class='summary'>"
	. += "<h2>[show_late_init ? "Late " : ""]Initialization Cost Analysis</h2>"
	. += "<b>Total [show_late_init ? "Late " : ""]Init Time:</b> [total_cost] ds ([round(total_cost / 10, 0.01)]s)<br>"
	. += "<b>Total Instances:</b> [total_count]<br>"
	. += "<b>Total Types:</b> [length(costs_to_use)]<br>"
	. += "<b>Average Cost:</b> [round(total_cost / max(total_count, 1), 0.001)] ds per instance<br>"
	. += "<b>Sorting by:</b> [sort_by_avg ? "Average time per instance" : "Total time"]"
	. += "</div>"

	. += "<script>"
	. += "function toggle(id) {"
	. += "  var elem = document.getElementById(id);"
	. += "  var exp = document.getElementById('exp_' + id);"
	. += "  if(elem.style.display === 'none') {"
	. += "    elem.style.display = 'block';"
	. += "    exp.innerHTML = '▼';"
	. += "  } else {"
	. += "    elem.style.display = 'none';"
	. += "    exp.innerHTML = '▶';"
	. += "  }"
	. += "}"
	. += "</script>"

	. += build_tree_html(cost_tree, total_cost, sort_by_avg)

/datum/controller/subsystem/atoms/proc/build_tree_html(list/tree, total_cost, sort_by_avg = FALSE)
	. = ""
	var/static/node_id = 0

	var/list/sorted_keys = list()
	for(var/key in tree)
		sorted_keys += key

	// she ubble on my sort till she top
	for(var/i in 1 to length(sorted_keys))
		for(var/j in 1 to length(sorted_keys) - 1)
			var/key1 = sorted_keys[j]
			var/key2 = sorted_keys[j + 1]
			var/val1 = sort_by_avg ? (tree[key1]["cost"] / max(tree[key1]["count"], 1)) : tree[key1]["cost"]
			var/val2 = sort_by_avg ? (tree[key2]["cost"] / max(tree[key2]["count"], 1)) : tree[key2]["cost"]
			if(val1 < val2)
				sorted_keys[j] = key2
				sorted_keys[j + 1] = key1

	for(var/key in sorted_keys)
		var/list/node = tree[key]
		var/cost = node["cost"]
		var/count = node["count"]
		var/direct_cost = node["direct_cost"]
		var/direct_count = node["direct_count"]
		var/avg_cost = round(cost / max(count, 1), 0.001)
		var/percentage = round((cost / total_cost) * 100, 0.01)

		node_id++
		var/current_id = "node[node_id]"

		var/cost_class = "cost-low"
		if(percentage >= 10)
			cost_class = "cost-high"
		else if(percentage >= 1)
			cost_class = "cost-med"

		var/has_children = length(node["children"]) > 0
		var/expander = has_children ? "<span class='expander' id='exp_[current_id]' onclick='toggle(\"[current_id]\")'>▼</span>" : "<span class='expander'>&nbsp;</span>"

		. += "<div class='tree-item'>"
		. += "[expander] <span class='[cost_class]'>[key]</span> "
		. += "- <b>[cost]ds</b> "
		. += "<span class='count'>([count]x)</span> "
		. += "<span class='avg'>[avg_cost]ds avg</span> "
		if(direct_cost > 0 && has_children)
			var/direct_avg = round(direct_cost / max(direct_count, 1), 0.001)
			. += "(direct: [direct_cost]ds, [direct_count]x, [direct_avg]ds avg) "
		. += "<span class='percentage'>([percentage]%)</span>"
		. += "</div>"

		if(has_children)
			. += "<div id='[current_id]' class='tree-node'>"
			. += build_tree_html(node["children"], total_cost, sort_by_avg)
			. += "</div>"

ADMIN_VERB(cmd_display_init_costs, R_DEBUG, FALSE, "Display Init Costs", "Displays initialization costs in a tree format", ADMIN_CATEGORY_DEBUG)
	if(alert(user, "Are you sure you want to view the initialization costs? This may take more than a minute to load.", "Confirm", "Yes", "No") != "Yes")
		return
	if(!LAZYLEN(SSatoms.init_costs))
		to_chat(user, span_notice("Init costs list is empty."))
	else
		user << browse(HTML_SKELETON(SSatoms.InitCostLog()), "window=initcosts;size=900x600")

/datum/controller/subsystem/atoms/Topic(href, href_list)
	. = ..()
	if(href_list["init_costs"])
		var/sort_by_avg = (href_list["sort"] == "avg")
		var/show_late_init = (href_list["mode"] == "late")
		usr << browse(HTML_SKELETON(InitCostLog(sort_by_avg, show_late_init)), "window=initcosts;size=900x600")

#endif

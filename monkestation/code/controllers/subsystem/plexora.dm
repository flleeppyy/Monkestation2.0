/**
 * # Plexora Subsystem
 *
 * This subsystem is for the Plexora Discord bot bridge.
 *
 * The repo for this can be found at https://github.com/monkestation/plexora
 *
 * The distinction between Plexora (the bot) and Plexora (the subsystem)
 * will be plexora (the bot) and SSplexora (the subsystem)
 *
 * NOTES:
 * * SSplexora makes heavy use of topics, and rust_g HTTP requests
 * * Lets hope to god plexora is configured properly and DOESNT CRASh,
 *	 -because i seriously do not want to put error catchers in
 *	 -EVERY FUNCTION THAT MAKES AN HTTP REQUEST
 */

#define TOPIC_EMITTER \
	if (input["emitter_token"]) { \
		INVOKE_ASYNC(SSplexora, TYPE_PROC_REF(/datum/controller/subsystem/plexora,topic_listener_response), input["emitter_token"], returning); \
		return; \
	};

#define AUTH_HEADER ("Basic " + CONFIG_GET(string/comms_key))

#define HTTP_DEFAULT_HEADERS(...) \
	var/list/headers = list(); \
	headers["Content-Type"] = "application/json"; \
	headers["Authorization"] = AUTH_HEADER;

SUBSYSTEM_DEF(plexora)
	name = "Plexora"
	wait = 30 SECONDS
	init_order = INIT_ORDER_PLEXORA
	priority = FIRE_PRIORITY_PLEXORA
	runlevels = ALL

	var/version_increment_counter = 1
	var/configuration_path = "config/plexora.json"
	var/plexora_is_alive = FALSE
	var/http_root = ""
	var/http_port = 0
	var/enabled = TRUE
	var/tripped_bad_version = FALSE

/datum/controller/subsystem/plexora/Initialize()
	if (!rustg_file_exists(configuration_path))
		stack_trace("SSplexora has no configuration file! (missing: [configuration_path])")
		enabled = FALSE
		return SS_INIT_FAILURE

	// Get config
	var/list/config = json_decode(rustg_file_read(configuration_path))

	if (!config["enabled"])
		enabled = FALSE
		return SS_INIT_NO_NEED

	var/comms_key = CONFIG_GET(string/comms_key)
	if (!comms_key)
		stack_trace("SSplexora is enabled BUT there is no configured comms key! Please make sure to set one and update Plexora's server config.")
		enabled = FALSE
		return SS_INIT_FAILURE

	http_root = config["ip"]
	http_port = config["port"]

	// Do a ping test to check if Plexora is actually running
	if (!isPlexoraAlive())
		stack_trace("SSplexora is enabled BUT plexora is not alive or running! SS has not been aborted, subsequent fires will take place.")
	else
		serverstarted()

	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(roundstarted))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/plexora/proc/isPlexoraAlive()
	if (!enabled) return;
	HTTP_DEFAULT_HEADERS()

	var/datum/http_request/request = new()
	request.prepare(
		RUSTG_HTTP_METHOD_GET,
		"http://[http_root]:[http_port]/alive",
		"",
		"",
	)
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if (response.errored)
		stack_trace("Failed to check if Plexora is alive! She probably isn't. Check config on both sides")
		plexora_is_alive = FALSE
		return FALSE
	else
		var/list/json_body = json_decode(response.body)
		if (json_body["version_increment_counter"] != version_increment_counter)
			if (!tripped_bad_version)
				stack_trace("SSplexora's version does not match Plexora! SSplexora: [version_increment_counter] Plexora: [json_body["version_increment_counter"]]")
				tripped_bad_version = TRUE

		plexora_is_alive = TRUE
		return TRUE

/datum/controller/subsystem/plexora/fire()
	if (!enabled) return;
	isPlexoraAlive()
	// Send current status to Plexora
	var/datum/world_topic/status/status_handler = new()
	var/list/status = status_handler.Run()

	HTTP_DEFAULT_HEADERS()

	var/datum/http_request/request = new()
	request.prepare(
		RUSTG_HTTP_METHOD_POST,
		"http://[http_root]:[http_port]/status",
		json_encode(status),
		headers,
		"tmp/response.json"
	)
	request.begin_async()
	UNTIL(request.is_complete())

/datum/controller/subsystem/plexora/Shutdown(hard = FALSE)
	var/list/body = list();
	body["type"] = "servershutdown"
	body["timestamp"] = rustg_unix_timestamp()
	body["roundid"] = GLOB.round_id
	body["round_timer"] = ROUND_TIME()
	body["map"] = SSmapping.config?.map_name
	body["playercount"] = length(GLOB.clients)
	body["hard"] = hard

	http_basicasync("serverupdates", body)

/datum/controller/subsystem/plexora/proc/serverstarted()
	var/list/body = list();
	body["type"] = "serverstart"
	body["timestamp"] = rustg_unix_timestamp()
	body["roundid"] = GLOB.round_id
	body["map"] = SSmapping.config?.map_name
	body["playercount"] = length(GLOB.clients)

	http_basicasync("serverupdates", body)

/datum/controller/subsystem/plexora/proc/serverinitdone(time)
	var/list/body = list();
	body["type"] = "serverinitdone"
	body["timestamp"] = rustg_unix_timestamp()
	body["roundid"] = GLOB.round_id
	body["map"] = SSmapping.config?.map_name
	body["playercount"] = length(GLOB.clients)
	body["init_time"] = time

	http_basicasync("serverupdates", body)

/datum/controller/subsystem/plexora/proc/roundstarted()
	var/list/body = list()
	body["type"] = "roundstart"
	body["timestamp"] = rustg_unix_timestamp()
	body["roundid"] = GLOB.round_id
	body["map"] = SSmapping.config?.map_name
	body["playercount"] = length(GLOB.clients)

	http_basicasync("serverupdates", body)

/datum/controller/subsystem/plexora/proc/roundended()
	var/list/body = list()
	body["type"] = "roundend"
	body["timestamp"] = rustg_unix_timestamp()
	body["roundid"] = GLOB.round_id
	body["round_timer"] = ROUND_TIME()
	body["map"] = SSmapping.config?.map_name
	body["nextmap"] = SSmapping.next_map_config?.map_name
	body["playercount"] = length(GLOB.clients)
	body["playerstring"] = "**Total**: [length(GLOB.clients)], **Living**: [length(GLOB.alive_player_list)], **Dead**: [length(GLOB.dead_player_list)], **Observers**: [length(GLOB.current_observers_list)]"

	http_basicasync("serverupdates", body)

/datum/controller/subsystem/plexora/proc/newinterview()
	var/list/body = list()
	// not done
	http_basicasync("serverupdates", body)

// note: recover_all_SS_and_recreate_master to force mc shit

/datum/controller/subsystem/plexora/proc/mc_alert(alert, level = 5)
	var/list/body = list()
	body["type"] = "mcalert"
	body["timestamp"] = rustg_unix_timestamp()
	body["roundid"] = GLOB.round_id
	body["round_timer"] = ROUND_TIME()
	body["map"] = SSmapping.config?.map_name
	body["playercount"] = length(GLOB.clients)
	body["playerstring"] = "**Total**: [length(GLOB.clients)], **Living**: [length(GLOB.alive_player_list)], **Dead**: [length(GLOB.dead_player_list)], **Observers**: [length(GLOB.current_observers_list)]"
	body["defconstring"] = alert
	body["defconlevel"] = level

	http_basicasync("serverupdates", body)

/datum/controller/subsystem/plexora/proc/new_note(list/note) {
	note["replay_pass"] = CONFIG_GET(string/replay_password)
	http_basicasync("noteupdates")
}

/datum/controller/subsystem/plexora/proc/new_ban(list/ban)
	// TODO: It might be easier to just send off a ban ID to Plexora, but oh well.
	// list values are in sql_ban_system.dm
	ban["replay_pass"] = CONFIG_GET(string/replay_password)
	http_basicasync("banupdates", ban)

// Maybe we should consider that, if theres no admin_ckey when creating a new ticket,
// This isnt a bwoink. Other wise if it does exist, it is a bwoink.
/datum/controller/subsystem/plexora/proc/aticket_new(datum/admin_help/ticket, msg_raw, is_bwoink, urgent, admin_ckey = null)
	if (!enabled) return;
	var/list/body = list();
	body["id"] = ticket.id
	body["roundid"] = GLOB.round_id
	body["round_timer"] = ROUND_TIME()
	body["world_time"] = world.time
	body["name"] = ticket.name
	body["ckey"] = ticket.initiator_ckey
	body["key_name"] = ticket.initiator_key_name
	body["is_bwoink"] = is_bwoink
	body["urgent"] = urgent
	body["msg_raw"] = msg_raw
	body["opened_at"] = rustg_unix_timestamp()
	body["replay_pass"] = CONFIG_GET(string/replay_password)
	body["icon_b64"] = icon2base64(getFlatIcon(ticket.initiator.mob, SOUTH, no_anim = TRUE))

	if (admin_ckey)	body["admin_ckey"] = admin_ckey

	http_basicasync("atickets/new", body)

/datum/controller/subsystem/plexora/proc/aticket_closed(datum/admin_help/ticket, closed_by, close_type = AHELP_CLOSETYPE_CLOSE, close_reason = AHELP_CLOSEREASON_NONE)
	if (!enabled) return;
	var/list/body = list();
	body["id"] = ticket.id
	body["roundid"] = GLOB.round_id
	body["closed_by"] = closed_by
	// Make sure the defines in __DEFINES/admin.dm match up with Plexora's code
	body["close_reason"] = close_reason
	body["close_type"] = close_type

	body["time_closed"] = rustg_unix_timestamp()

	http_basicasync("atickets/close", body)

/datum/controller/subsystem/plexora/proc/aticket_reopened(datum/admin_help/ticket, reopened_by)
	if (!enabled) return;
	var/list/body = list();
	body["id"] = ticket.id
	body["roundid"] = GLOB.round_id
	body["time_reopened"] = rustg_unix_timestamp()
	body["reopened_by"] = reopened_by // ckey

	http_basicasync("atickets/reopen", body)

/datum/controller/subsystem/plexora/proc/aticket_pm(datum/admin_help/ticket, message, admin_ckey = null)
	if (!enabled) return;
	var/list/body = list();
	body["id"] = ticket.id
	body["roundid"] = GLOB.round_id
	body["message"] = message

	// We are just.. going to assume that if there is no admin_ckey param,
	// that the person sending the message is not an admin.
	// no admin_ckey = user is the initiator

	if (admin_ckey)	body["admin_ckey"] = admin_ckey

	http_basicasync("atickets/pm", body)

/datum/controller/subsystem/plexora/proc/aticket_connection(datum/admin_help/ticket, is_disconnect = TRUE)
	if (!enabled) return;
	var/list/body = list()
	body["id"] = ticket.id
	body["roundid"] = GLOB.round_id
	body["is_disconnect"] = is_disconnect
	body["time_of_connection"] = rustg_unix_timestamp()

	http_basicasync("atickets/connection_notice", body)

// Begin Mentor tickets

/datum/controller/subsystem/plexora/proc/mticket_new(datum/request/ticket)
	if (!enabled) return;

	var/list/body = list()
	body["id"] = ticket.id
	body["ckey"] = ticket.owner_ckey
	body["key_name"] = ticket.owner_name
	body["roundid"] = GLOB.round_id
	body["round_timer"] = ROUND_TIME()
	body["world_time"] = world.time
	body["opened_at"] = rustg_unix_timestamp()
	body["icon_b64"] = icon2base64(getFlatIcon(ticket.owner.mob, SOUTH, no_anim = TRUE))
	body["replay_pass"] = CONFIG_GET(string/replay_password)
	body["message"] = ticket.message

	http_basicasync("mtickets/new", body)

/datum/controller/subsystem/plexora/proc/mticket_pm(datum/request/ticket, mob/frommob, mob/tomob, msg,)
	var/list/body = list()
	body["id"] = ticket.id
	body["from_ckey"] = frommob.ckey
	body["from_key_name"] = frommob.ckey
	body["ckey"] = tomob.ckey
	body["key_name"] = tomob.key
	body["roundid"] = GLOB.round_id
	body["round_timer"] = ROUND_TIME()
	body["world_time"] = world.time
	body["timestamp"] = rustg_unix_timestamp()
	body["icon_b64"] = icon2base64(getFlatIcon(frommob, SOUTH, no_anim = TRUE))
	body["message"] = msg

	http_basicasync("mtickets/pm", body)

/datum/controller/subsystem/plexora/proc/topic_listener_response(token, data)
	if (!enabled) return;
	var/list/body = list()
	body["token"] = token
	body["data"] = data
	http_basicasync("topic_emitter", body)

/datum/controller/subsystem/plexora/proc/http_basicasync(path, list/body)
	if (!enabled) return;
	HTTP_DEFAULT_HEADERS()

	var/datum/http_request/request = new()
	request.prepare(
		RUSTG_HTTP_METHOD_POST,
		"http://[http_root]:[http_port]/[path]",
		json_encode(body),
		headers,
		"tmp/response.json"
	)
	request.begin_async()

/datum/world_topic/plx_who
	keyword = "PLX_who"
	require_comms_key = TRUE

/datum/world_topic/plx_who/Run(list/input)
	var/list/players = list()

	for(var/client/client in GLOB.clients)
		if(client.holder && client.holder.fakekey)
			players += list(list("key" = client.holder.fakekey, "avgping" = "[round(client.avgping, 1)]ms"))
		else
			players += list(list("key" = client.key, "avgping" = "[round(client.avgping, 1)]ms"))

	return players

/datum/world_topic/plx_adminwho
	keyword = "PLX_adminwho"
	require_comms_key = TRUE

/datum/world_topic/plx_adminwho/Run(list/input)
	var/list/admins = list()

	for (var/client/admin in GLOB.admins)
		var/admin_ = list(
			"name" = admin,
			"ckey" = admin.ckey,
			"rank" = admin.holder.rank_names(),
			"afk" = admin.is_afk(),
			"stealth" = !!admin.holder.fakekey,
			"stealthkey" = admin.holder.fakekey,
		)

		if(isobserver(admin.mob))
			admin_["state"] = "observing"
		else if(isnewplayer(admin.mob))
			admin_["state"] = "lobby"
		else
			admin_["state"] = "playing"

		admins += LIST_VALUE_WRAP_LISTS(admin_)
	return admins

/datum/world_topic/plx_mentorwho
	keyword = "PLX_mentorwho"
	require_comms_key = TRUE

/datum/world_topic/plx_mentorwho/Run(list/input)
	var/list/mentors = list()

	for (var/client/mentor in GLOB.mentors)
		var/list/mentor_ = list(
			"name" = mentor,
			"ckey" = mentor.ckey,
			"rank" = mentor.holder.rank_names(),
			"afk" = mentor.is_afk(),
			"stealth" = !!mentor.holder.fakekey,
			"stealthkey" = mentor.holder.fakekey,
		)

		if(isobserver(mentor.mob))
			mentor_["state"] = "observing"
		else if(isnewplayer(mentor.mob))
			mentor_["state"] = "lobby"
		else
			mentor_["state"] = "playing"

		mentors += LIST_VALUE_WRAP_LISTS(mentor_)

	return mentors

/datum/world_topic/plx_getsmites
	keyword = "PLX_getsmites"
	require_comms_key = TRUE

/datum/world_topic/plx_getsmites/Run(list/input)
	var/list/availableSmites = list()

	for (var/_smite_path in subtypesof(/datum/smite))
		var/datum/smite/smite_path = _smite_path
		try
			if ((new smite_path).configure(new /datum/client_interface("fake_player")) == "NO_CONFIG")
				availableSmites[initial(smite_path.name)] = smite_path
		catch

	return availableSmites

/datum/world_topic/plx_gettwitchevents
	keyword = "PLX_gettwitchevents"
	require_comms_key = TRUE

/datum/world_topic/plx_gettwitchevents/Run(list/input)
	var/list/events = list()

	for (var/_event_path in subtypesof(/datum/twitch_event))
		var/datum/twitch_event/event_path = _event_path
		events[initial(event_path.event_name)] = event_path

	return events

/datum/world_topic/plx_getbasicplayerdetails
	keyword = "PLX_getbasicplayerdetails"
	require_comms_key = TRUE

/datum/world_topic/plx_getbasicplayerdetails/Run(list/input)
	var/ckey = input["ckey"]

	if (!ckey)
		return list("error" = "missingckey")

	var/list/returning = list()

	var/client/client = disambiguate_client(ckey)

	if (client)
		returning["present"] = FALSE
	else
		returning["present"] = TRUE
		returning["ckey"] = ckey
		returning["key"] = client.key

	var/datum/player_details/details = GLOB.player_details[ckey]

	if (details)
		returning["byond_version"] = details.byond_version

	if (isnull(client))
		var/datum/client_interface/mock_player = new(ckey)
		mock_player.prefs = new /datum/preferences(mock_player)
		returning["playtime"] = mock_player.get_exp_living(FALSE);
	else
		returning["playtime"] = client.get_exp_living(FALSE);

	return returning

/datum/world_topic/plx_getplayerdetails
	keyword = "PLX_getplayerdetails"
	require_comms_key = TRUE

/datum/world_topic/plx_getplayerdetails/Run(list/input)
	var/ckey = input["ckey"]
	var/omit_logs = input["omit_logs"]

	if (!ckey)
		return list("error" = "missingckey")

	var/datum/player_details/details = GLOB.player_details[ckey]

	if (!details)
		return list("error" = "detailsnotexist")

	var/client/client = disambiguate_client(ckey)

	if (!client)
		return list("error" = "clientnotexist")

	var/list/returning = list()

	returning["ckey"] = ckey
	returning["key"] = client.key
	returning["admin_datum"] = null
	if (!omit_logs) returning["logging"] = details.logging
	returning["played_names"] = details.played_names
	returning["byond_version"] = details.byond_version
	returning["achievements"] = details.achievements.data
	returning["playtime"] = client.get_exp_living(FALSE);

	if (GLOB.admin_datums[ckey])
		returning["admin_datum"] = list(
			"name" = GLOB.admin_datums[ckey].name,
			"ranks" = GLOB.admin_datums[ckey].ranks,
			"fakekey" = GLOB.admin_datums[ckey].fakekey,
			"deadmined" = GLOB.admin_datums[ckey].deadmined,
			"bypass_2fa" = GLOB.admin_datums[ckey].bypass_2fa,
			"admin_signature" = GLOB.admin_datums[ckey].admin_signature,
		)

	returning["mob"] = list(
		"name" = client.mob.name,
		"real_name" = client.mob.real_name,
		"type" = client.mob.type,
		"gender" = client.mob.gender,
		"stat" = client.mob.stat,
	)
	if (isliving(client.mob))
		var/mob/living/livingmob = client.mob
		returning["health"] = livingmob.health
		returning["maxHealth"] = livingmob.maxHealth
		returning["bruteloss"] = livingmob.bruteloss
		returning["fireloss"] = livingmob.fireloss
		returning["toxloss"] = livingmob.toxloss
		returning["oxyloss"] = livingmob.oxyloss

	TOPIC_EMITTER

	return returning

/datum/world_topic/plx_forceemote
	keyword = "PLX_forceemote"
	require_comms_key = TRUE

/datum/world_topic/plx_forceemote/Run(list/input)
	var/target_ckey = input["ckey"]
	var/emote = input["emote"]
	var/emote_args = input["emote_args"]

	var/client/client = disambiguate_client(ckey(target_ckey))

	if (!client)
		return list("error" = "clientnotexist")

	var/mob/client_mob = client.mob

	if (!client_mob)
		return list("error" = "clientnomob")

	return list(
		"success" = client_mob.emote(emote, message = emote_args, intentional = FALSE)
	);

/datum/world_topic/plx_forcesay
	keyword = "PLX_forcesay"
	require_comms_key = TRUE

/datum/world_topic/plx_forcesay/Run(list/input)
	var/target_ckey = input["ckey"]
	var/message = input["message"]

	var/client/client = disambiguate_client(ckey(target_ckey))

	if (!client)
		return list("error" = "clientnotexist")

	var/mob/client_mob = client.mob

	if (!client_mob)
		return list("error" = "clientnomob")

	client_mob.say(message, forced = TRUE)

/datum/world_topic/plx_runtwitchevent
	keyword = "plx_runtwitchevent"
	require_comms_key = TRUE

/datum/world_topic/plx_runtwitchevent/Run(list/input)
	var/event = input["event"]
	// TODO: do something with the executor input
	//var/executor = input["executor"]

	if (!CONFIG_GET(string/twitch_key))
		return list("error" = "twitchkeynotconfigured")

	// cant be bothered, lets just call the topic.
	var/outgoing = list("TWITCH-API", CONFIG_GET(string/twitch_key), event,)
	SStwitch.handle_topic(outgoing)

/datum/world_topic/plx_smite
	keyword = "PLX_smite"
	require_comms_key = TRUE

/datum/world_topic/plx_smite/Run(list/input)
	var/target_ckey = input["ckey"]
	var/selected_smite = input["smite"]
	var/smited_by = input["smited_by_ckey"]

	if (!GLOB.smites[selected_smite])
		return "error=invalidsmite"

	var/client/client = disambiguate_client(target_ckey)

	if (!client)
		return list("error" = "clientnotexist")

	// DIVINE SMITING!
	var/smite_path = GLOB.smites[selected_smite]
	var/datum/smite/picking_smite = new smite_path
	var/configuration_success = picking_smite.configure(client)
	if (configuration_success == FALSE)
		return

	// Mock admin
	var/datum/client_interface/mockadmin = new(
		key = smited_by,
	)

	usr = mockadmin
	picking_smite.effect(client, client.mob)

/datum/world_topic/plx_jailmob
	keyword = "PLX_jailmob"
	require_comms_key = TRUE

/datum/world_topic/plx_jailmob/Run(list/input)
	var/ckey = input["ckey"]
	var/jailer = input["admin_ckey"]

	var/client/client = disambiguate_client(ckey)

	if (!client)
		return list("error" = "clientnotexist")

	var/mob/client_mob = client.mob

	if (!client_mob)
		return list("error" = "clientnomob")

	// Mock admin
	var/datum/client_interface/mockadmin = new(
		key = jailer,
	)

	usr = mockadmin

	client_mob.forceMove(pick(GLOB.prisonwarp))
	to_chat(client_mob, span_adminnotice("You have been sent to Prison!"), confidential = TRUE)

	log_admin("Discord: [key_name(usr)] has sent [key_name(client_mob)] to Prison!")
	message_admins("Discord: [key_name_admin(usr)] has sent [key_name_admin(client_mob)] to Prison!")

/datum/world_topic/plx_ticketaction
	keyword = "PLX_ticketaction"
	require_comms_key = TRUE

/datum/world_topic/plx_ticketaction/Run(list/input)
	var/ticketid = input["id"]
	var/action_by_ckey = input["action_by"]
	var/action = input["action"]


	var/datum/client_interface/mockadmin = new(
		key = action_by_ckey,
	)

	usr = mockadmin

	var/datum/admin_help/ticket = GLOB.ahelp_tickets.TicketByID(ticketid)
	if (!ticket) return list("error" = "couldntfetchticket")

	if (action != "reopen" && ticket.state != AHELP_ACTIVE)
		return

	switch(action)
		if("reopen")
			if (ticket.state == AHELP_ACTIVE) return
			SSplexora.aticket_reopened(ticket, action_by_ckey)
			ticket.Reopen()
		if("reject")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_REJECT)
			ticket.Reject(action_by_ckey)
		if("icissue")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_RESOLVE, AHELP_CLOSEREASON_IC)
			ticket.ICIssue(action_by_ckey)
		if("close")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_CLOSE)
			ticket.Close(action_by_ckey)
		if("resolve")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_RESOLVE)
			ticket.Resolve(action_by_ckey)
		if("mhelp")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_CLOSE, AHELP_CLOSEREASON_MENTOR)
			ticket.MHelpThis(action_by_ckey)

/datum/world_topic/plx_sendaticketpm
	keyword = "PLX_sendaticketpm"
	require_comms_key = TRUE

/datum/world_topic/plx_sendaticketpm/Run(list/input)
	// We're kind of copying /proc/TgsPm here...
	var/ticketid = text2num(input["ticket_id"])
	var/input_ckey = input["ckey"]
	var/sender = input["sender_ckey"]
	var/stealth = input["stealth"]
	var/message = input["message"]

	var/requested_ckey = ckey(input_ckey)
	var/client/recipient = disambiguate_client(requested_ckey)

	if (!recipient)
		return list("error" = "clientnotexist")

	var/datum/admin_help/ticket
	if (ticketid)
		ticket = GLOB.ahelp_tickets.TicketByID(ticketid)
	else
		ticket = GLOB.ahelp_tickets.CKey2ActiveTicket(requested_ckey)

	if (!ticket)
		return list("error" = "couldntfetchticket")

	var/plx_tagged = "[sender](Plexora/External)"

	var/adminname = stealth ? "Administrator" : plx_tagged
	var/stealthkey = GetTgsStealthKey()

	message = sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN))
	message = emoji_parse(message)

	if (!message)
		return list("error" = "sanitizationfailed")

	// I have no idea what this does honestly.


	// The ckey of our recipient, with a reply link, and their mob if one exists
	var/recipient_name_linked = key_name_admin(recipient)
	// The ckey of our recipient, with their mob if one exists. No link
	var/recipient_name = key_name_admin(recipient)

	message_admins("External message from [sender] to [recipient_name_linked] : [message]")
	log_admin_private("External PM: [sender] -> [recipient_name] : [message]")

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>",
		confidential = TRUE)

	recipient.receive_ahelp(
		"<a href='?priv_msg=[stealthkey]'>[adminname]</a>",
		message,
	)

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("<i>Click on the administrator's name to reply.</i>"),
		confidential = TRUE)


	admin_ticket_log(recipient, "<font color='purple'>PM From [adminname]: [message]</font>", log_in_blackbox = FALSE)

	window_flash(recipient, ignorepref = TRUE)
	// Nullcheck because we run a winset in window flash and I do not trust byond
	if(recipient)
		//always play non-admin recipients the adminhelp sound
		SEND_SOUND(recipient, 'sound/effects/adminhelp.ogg')

		recipient.externalreplyamount = EXTERNALREPLYCOUNT

/datum/world_topic/plx_sendmticketpm
	keyword = "PLX_sendmticketpm"
	require_comms_key = TRUE

/datum/world_topic/plx_sendmticketpm/Run(list/input)
	var/ticketid = input["ticket_id"]
	var/target_ckey = input["ckey"]
	var/sender = input["sender_ckey"]
	var/message = input["message"]

	var/client/recipient = disambiguate_client(ckey(target_ckey))

	if (!recipient)
		return list("error" = "clientnotexist")

	var/datum/request/request = GLOB.mentor_requests.requests_by_id[ticketid]

	recipient << 'sound/items/bikehorn.ogg'
	to_chat(recipient, "<font color='purple'>Mentor PM from-<b>[key_name_mentor(sender, recipient, TRUE, FALSE, FALSE)]</b>: [message]</font>")

#undef AUTH_HEADER
#undef HTTP_DEFAULT_HEADERS
#undef TOPIC_EMITTER

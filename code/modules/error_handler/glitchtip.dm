// This might be compatible with sentry, I'm not sure, my trial period expired so I can't test lol
// Configuration options are in entries/general.dm

// TODO: Remove with introduction of Rust-g 3.12.0, and use `rustg_generate_uuid_v4`
// OR
// TODO: Remove with introduction of Aneri, and use `aneri_uuid`
/proc/generate_simple_uuid()
	var/uuid = ""
	for(var/i = 1 to 32)
		uuid += pick("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f")
		if(i == 8 || i == 12 || i == 16 || i == 20)
			uuid += "-"
	return uuid

/proc/send_to_glitchtip(exception/E, list/extra_data = null)
	if(!CONFIG_GET(flag/glitchtip_enabled) || !CONFIG_GET(string/glitchtip_dsn))
		return

	var/glitchtip_dsn = CONFIG_GET(string/glitchtip_dsn)

	// parse DSN to get the key, host and project id
	var/dsn_clean = replacetext(replacetext(glitchtip_dsn, "http://", ""), "https://", "")
	var/at_pos = findtext(dsn_clean, "@")
	var/slash_pos = findtext(dsn_clean, "/", at_pos)

	if(!at_pos || !slash_pos)
		log_runtime("Invalid Glitchtip DSN format")
		return

	var/key = copytext(dsn_clean, 1, at_pos)
	var/host = copytext(dsn_clean, at_pos + 1, slash_pos)
	var/project_id = copytext(dsn_clean, slash_pos + 1)

	var/list/event_data = list()
	event_data["event_id"] = generate_simple_uuid()
	event_data["timestamp"] = time_stamp_metric()
	event_data["level"] = "error"
	event_data["platform"] = world.system_type
	event_data["server_name"] = world.name
	event_data["environment"] = CONFIG_GET(string/glitchtip_environment)

	event_data["sdk"] = list(
		"name" = "byond-glitchtip",
		"version" = "1.0.0"
	)

	var/list/exception_data = list()
	exception_data["type"] = "BYOND Runtime Error"
	exception_data["value"] = E.name
	exception_data["module"] = E.file

	// parse stack trace from BYOND error description
	var/list/frames = list()
	var/list/stack_lines = splittext(E.desc, "\n")
	var/current_proc = "unknown"

	for(var/line in stack_lines)
		line = trim(line)
		if(!line || length(line) < 3)
			continue

		// Extract proc name
		if(findtext(line, "proc name:"))
			current_proc = copytext(line, findtext(line, ":") + 2)
			continue

		// Extract source file path
		if(findtext(line, "source file:"))
			var/file_info = copytext(line, findtext(line, ":") + 2)
			var/comma_pos = findtext(file_info, ",")
			if(comma_pos)
				var/filename = copytext(file_info, 1, comma_pos)
				var/line_num = text2num(copytext(file_info, comma_pos + 1))

				var/list/frame = list()
				frame["filename"] = filename
				frame["lineno"] = line_num || E.line
				frame["function"] = current_proc
				frame["in_app"] = TRUE
				frames += list(frame)

	// If no frames parsed, create a basic one
	if(!length(frames))
		var/list/frame = list()
		frame["filename"] = E.file
		frame["lineno"] = E.line
		frame["function"] = "unknown"
		frame["in_app"] = TRUE
		frames += list(frame)

	exception_data["stacktrace"] = list("frames" = frames)
	event_data["exception"] = list("values" = list(exception_data))

	// User context
	if(istype(usr))
		var/list/user_data = list()
		user_data["key"] = usr.key
		user_data["character_name"] = usr.name
		user_data["character_realname"] = usr.real_name
		user_data["character_mobtype"] = usr.type
		user_data["character_job"] = usr?.job
		if(usr.client)
			user_data["byond_version"] = usr.client.byond_version
			user_data["byond_build"] = usr.client.byond_build
			// user_data["ip_address"] = usr.client.address
			// user_data["computer_id"] = usr.client.computer_id
			user_data["holder"] = usr.client.holder?.name
		event_data["user"] = user_data

		// Add location context
		var/locinfo = loc_name(usr)
		if(locinfo)
			if(!extra_data)
				extra_data = list()
			extra_data["user_location"] = locinfo

	if(extra_data)
		event_data["extra"] = extra_data

	// Tags for filtering in Glitchtip
	event_data["tags"] = list(
		"round_id" = GLOB.round_id,
		"file" = E.file,
		"line" = "[E.line]",
		"byond_version" = DM_VERSION,
		"byond_build" = DM_BUILD,
	)

	event_data["fingerprint"] = list("[E.file]:[E.line]", E.name)

	send_glitchtip_request(event_data, host, project_id, key)

/proc/send_glitchtip_request(list/event_data, host, project_id, key)
	var/glitchtip_url = "https://[host]/api/[project_id]/store/"
	var/json_payload = json_encode(event_data)

	// Glitchtip/Sentry auth header - According to docs this needs to be like this
	var/auth_header = "Sentry sentry_version=7, sentry_client=byond-glitchtip/1.0.0, sentry_key=[key], sentry_timestamp=[time_stamp_metric()]"

	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, glitchtip_url, json_payload, list(
		"X-Sentry-Auth" = auth_header,
		"Content-Type" = "application/json",
		"User-Agent" = get_useragent("Glitchtip-Implementation")
	))
	request.begin_async()

SUBSYSTEM_DEF(floxy)
	name = "Floxy"
	wait = 1 SECONDS
	runlevels = ALL
	init_order = INIT_ORDER_FLOXY
#ifdef UNIT_TESTS
	flags = SS_NO_INIT | SS_NO_FIRE
#else
	flags = SS_HIBERNATE
#endif
	/// Base URL for Floxy.
	var/base_url
	/// List of IDs that we're waiting on results from.
	var/list/pending_ids = list()
	/// Assoc list of [id] -> completed requests.
	/// If a value is null, that means it errored somehow, and floxy.log should be checked for more info.
	var/alist/completed_ids = alist()
	/// world.realtime value of when the current auth token will expire
	var/auth_expiry
	/// Auth token used for the header.
	VAR_PRIVATE/auth_token

	var/static/list/default_headers = list(
		"Content-Type" = "application/json",
		"Accept" = "application/json",
	)

/datum/controller/subsystem/floxy/PreInit()
	. = ..()
	hibernate_checks = list(
		NAMEOF(src, pending_ids),
	)

/datum/controller/subsystem/floxy/Initialize()
	base_url = CONFIG_GET(string/floxy_url)
	var/username = CONFIG_GET(string/floxy_username)
	var/password = CONFIG_GET(string/floxy_password)
	if(!base_url || !username || !password)
		flags |= SS_NO_FIRE
		return SS_INIT_NO_NEED
	if(!login(username, password))
		return SS_INIT_FAILURE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/floxy/Recover()
	base_url = SSfloxy.base_url
	pending_ids = SSfloxy.pending_ids
	completed_ids = SSfloxy.completed_ids
	auth_expiry = SSfloxy.auth_expiry
	auth_token = SSfloxy.auth_token

/datum/controller/subsystem/floxy/fire(resumed)
	renew_if_needed()
	for(var/id in pending_ids)
		var/list/info = http_basicasync("api/media/[id]", method = RUSTG_HTTP_METHOD_GET)
		if(!info)
			pending_ids -= id
			continue
		var/status = info["status"]
		if(status != "completed" && status != "failed")
			continue
		pending_ids -= id
		log_floxy("[id] [status]")
		testing("FLOXY: [id] [status]\n---[json_encode(info, JSON_PRETTY_PRINT)]\n---")
		completed_ids[id] = info

/datum/controller/subsystem/floxy/stat_entry(msg)
	if(auth_token)
		msg += "Authenticated | Pending: [length(pending_ids)] | Completed: [length(completed_ids)]"
		if(auth_expiry)
			msg += " | Renews in [DisplayTimeText(auth_expiry - world.realtime, 60)])"
	else
		msg = "Unauthenticated"
	return ..()

#ifndef TESTING
/datum/controller/subsystem/floxy/can_vv_get(var_name)
	if(var_name == NAMEOF(src, auth_token) || var_name == NAMEOF(src, default_headers) || var_name == NAMEOF(src, base_url))
		return FALSE
	return ..()

/datum/controller/subsystem/floxy/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, auth_token) || var_name == NAMEOF(src, default_headers) || var_name == NAMEOF(src, base_url))
		return FALSE
	return ..()

/datum/controller/subsystem/floxy/CanProcCall(procname)
	if(procname == "login" || procname == "http_basicasync")
		return FALSE
	return ..()
#endif

/datum/controller/subsystem/floxy/proc/queue(url, profile = "ogg-opus", ttl)
	if(!url)
		CRASH("No URL passed to SSfloxy.queue")
	if(!is_http_protocol(url))
		CRASH("Invalid URL passed to SSfloxy.queue")
	renew_if_needed()
	var/list/params = list("url" = url)
	if(profile)
		params["profile"] = profile
	if(ttl)
		params["ttl"] = ttl
	var/list/response = http_basicasync("api/media/queue?[list2params(params)]")
	if(!response)
		return FALSE
	var/id = response["id"]
	if(!id)
		CRASH("Queue didn't return ID?")
	var/url = response["url"]
	if(id in pending_ids)
		log_floxy("Ignoring duplicate queue attempt: [url] (ID: [id])")
		return id
	if(response["status"] == "completed")
		completed_ids[id] = response
		log_floxy("[url] was already completed (ID: [id])")
	else
		pending_ids |= id
		log_floxy("Queued [url] (ID: [id])")
	return id

/datum/controller/subsystem/floxy/proc/login(username, password)
	auth_token = null
	auth_expiry = null
	if(!username || !password)
		log_floxy("No username/password given for Floxy login!")
		return FALSE
	var/list/account_info = http_basicasync("api/login", list("username" = username, "password" = password), timeout = 5 SECONDS, auth = FALSE)
	if(!account_info)
		return FALSE
	auth_token = account_info["token"]
	var/list/jwt_info = parse_jwt_payload(auth_token)
	if(jwt_info?["exp"])
		auth_expiry = ((jwt_info["exp"] - 946684800) * 10) - 1 MINUTES // convert unix timestamp to world.realtime, but 1 minute earlier bc i don't trust this shit to be accurate
	var/list/user_info = account_info["user"]
	log_floxy("Logged into Floxy as [user_info["username"]] ([user_info["email"]], [user_info["id"]])")
	testing("FLOXY: logged in\n---\n[json_encode(account_info, JSON_PRETTY_PRINT)]]\n---")
	return TRUE

/datum/controller/subsystem/floxy/proc/renew_if_needed()
	if(!auth_token || !auth_expiry || auth_expiry > world.realtime)
		return
	var/username = CONFIG_GET(string/floxy_username)
	var/list/new_info = http_basicasync("api/token", list("username" = username), timeout = 5 SECONDS)
	if(!new_info)
		return
	auth_token = new_info["token"]
	var/list/jwt_info = parse_jwt_payload(auth_token)
	if(jwt_info?["exp"])
		auth_expiry = ((jwt_info["exp"] - 946684800) * 10) - 1 MINUTES
	else
		auth_expiry = null

/datum/controller/subsystem/floxy/proc/http_basicasync(path, list/body, method = RUSTG_HTTP_METHOD_POST, decode_json = TRUE, timeout = 10 SECONDS, auth = TRUE)
	var/list/headers = default_headers
	if(auth)
		headers = default_headers.Copy()
		headers["Authorization"] = "Bearer [auth_token]"
	var/datum/http_request/request = new(
		method,
		"[base_url]/[path]",
		json_encode(body),
		headers
	)
	request.begin_async()
	UNTIL_OR_TIMEOUT(request.is_complete(), timeout)
	var/datum/http_response/response = request.into_response()
	if(response.errored)
		log_floxy("Floxy response errored: status code [response.status_code]")
		CRASH("Floxy response errored: status code [response.status_code]")
	else if(decode_json)
		return json_decode(response.body)
	else
		return response.body

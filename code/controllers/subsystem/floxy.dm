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
	/// List of queue IDs we're waiting on results from.
	var/list/pending_ids = list()
	/// Assoc list of [id] -> completed requests
	var/alist/completed_ids = alist()
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
	auth_token = SSfloxy.auth_token

/datum/controller/subsystem/floxy/stat_entry(msg)
	if(auth_token)
		msg = "Authenticated | Pending: [length(pending_ids)] | Completed: [length(completed_ids)]"
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
	if(procname == "login")
		return FALSE
	return ..()
#endif

/datum/controller/subsystem/floxy/proc/login(username, password)
	auth_token = null
	if(!username || !password)
		log_floxy("No username/password given for Floxy login!")
		return FALSE
	var/list/account_info = http_basicasync("api/login", list("username" = username, "password" = password), timeout = 5 SECONDS, auth = FALSE)
	if(!account_info)
		return FALSE
	auth_token = account_info["token"]
	var/list/user_info = account_info["user"]
	log_floxy("Logged into Floxy as [user_info["username"]] ([user_info["email"]], [user_info["id"]])")
	testing("floxy login info: [json_encode(account_info, JSON_PRETTY_PRINT)]")
	return TRUE

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

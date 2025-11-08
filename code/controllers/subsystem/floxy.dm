SUBSYSTEM_DEF(floxy)
	name = "Floxy"
	wait = 10
	flags = SS_TICKER
	runlevels = ALL
	init_order = INIT_ORDER_FLOXY
	/// Base URL for Floxy.
	var/base_url
	/// Auth token used for the header.
	VAR_PRIVATE/auth_token

/datum/controller/subsystem/floxy/Initialize()
	base_url = CONFIG_GET(string/floxy_url)
	var/username = CONFIG_GET(string/floxy_username)
	var/password = CONFIG_GET(string/floxy_password)
	if(!base_url || !username || !password)
		flags |= SS_NO_FIRE
		return SS_INIT_NO_NEED
	return SS_INIT_SUCCESS

/datum/controller/subsystem/floxy/Recover()
	base_url = SSfloxy.base_url
	auth_token = SSfloxy.auth_token

/datum/controller/subsystem/floxy/can_vv_get(var_name)
	if(var_name == NAMEOF(src, auth_token))
		return FALSE
	return ..()

/datum/controller/subsystem/floxy/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, auth_token) || var_name == NAMEOF(src, base_url))
		return FALSE
	return ..()

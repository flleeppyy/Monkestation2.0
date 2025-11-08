SUBSYSTEM_DEF(floxy)
	name = "Floxy"
	wait = 10
	flags = SS_TICKER
	runlevels = ALL
	init_order = INIT_ORDER_FLOXY
	/// Auth token used for the header.
	VAR_PRIVATE/auth_token

/datum/controller/subsystem/floxy/can_vv_get(var_name)
	if(var_name == NAMEOF(src, auth_token))
		return FALSE
	return ..()

/datum/controller/subsystem/floxy/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, auth_token))
		return FALSE
	return ..()

/// action must be one of PLEXORA_NOTIFYSIGNUP
/datum/controller/subsystem/plexora/proc/notify_signup(ckey, action)
	var/list/response = http_basicasync("notify_enroll", list(
		"ckey" = ckey(ckey),
		"action" = action
	), TRUE, TRUE)

	if (isnum(response))
		return FALSE

	return response["result"]

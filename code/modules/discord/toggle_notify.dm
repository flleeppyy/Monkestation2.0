/client
	COOLDOWN_DECLARE(notify_toggle_cooldown)

// Verb to toggle restart notifications
/client/verb/notify_restart()
	set category = "OOC"
	set name = "Notify Restart"
	set desc = "Notifies you on Discord when the server restarts."

	// Safety checks
	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(src, span_warning("This feature requires the SQL backend to be running."))
		return

	if(!SSplexora) // SS is still starting
		to_chat(src, span_notice("The server is still starting up. Please wait before attempting to link your account "))
		return

	if(!SSplexora.enabled)
		to_chat(src, span_warning("This feature requires the server is running on the TGS toolkit"))
		return

	var/stored_id = SSplexora.lookup_id(usr.ckey)
	if(!stored_id) // Account is not linked
		to_chat(src, span_warning("This requires you to link your Discord account with the \"Link Discord Account\" verb."))
		return

	if (!COOLDOWN_FINISHED(src, notify_toggle_cooldown))
		to_chat(src, span_warning("Notify toggle on cooldown! ([COOLDOWN_TIMELEFT(src, notify_toggle_cooldown) * 0.1]s)"))

	COOLDOWN_START(src, notify_toggle_cooldown, 5 SECONDS)

	var/result = SSplexora.notify_signup(ckey)

	if (!result)
		to_chat(src, span_warning("Failed to toggle your notify status!"))

	if (result == PLEXORA_NOTIFYSIGNUP_ENROLL)
		to_chat(src, span_notice("You will now be notified when the server restarts"))
	else if (result == PLEXORA_NOTIFYSIGNUP_UNENROLL)
		to_chat(src, span_notice("You will no longer be notified when the server restarts"))
	else
		to_chat(src, span_warning("Plexora gave unexpected response, and was unable to toggle your notify status"))
		stack_trace("Unexpected response for notify_signup, [result]")

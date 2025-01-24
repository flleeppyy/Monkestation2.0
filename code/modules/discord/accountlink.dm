// IF you have linked your account, this will trigger a verify of the user
/client/verb/verify_in_discord()
	set category = "OOC"
	set name = "Verify Discord Account"
	set desc = "Verify your discord account with your BYOND account"

	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(src, span_warning("This feature requires the SQL backend to be running."))
		return

	if(!SSplexora || !SSplexora.reverify_cache)
		// This should NOT fucking happen under any circumstance.
		to_chat(src, span_warning("Wait for the Discord subsystem to finish initialising"))
		return
	var/message = ""
	// Simple sanity check to prevent a user doing this too often
	var/cached_one_time_token = SSplexora.reverify_cache[ckey]
	if(cached_one_time_token && cached_one_time_token != "")
		message = "You already generated your one time token, it is [cached_one_time_token], if you need a new one, you will have to wait until the round ends, or switch to another server, try verifying yourself in discord by using the command <span class='warning'>\" /verifydiscord token:[cached_one_time_token] \"</span><br>If that doesn't work, type in /verifydiscord to show the command, then copy and paste the token." // monkestation edit: PLEXORA

	else
		// Will generate one if an expired one doesn't exist already, otherwise will grab existing token
		var/one_time_token = SSplexora.get_or_generate_one_time_token_for_ckey(ckey)
		SSplexora.reverify_cache[ckey] = one_time_token
		message = "Your one time token is: [one_time_token], you can now verify yourself in discord by using the command <span class='warning'>\" /verifydiscord token:[one_time_token] \"</span><br>If that doesn't work, type in /verifydiscord to show the command, then copy and paste the token." // monkestation edit: PLEXORA

	//Now give them a browse window so they can't miss whatever we told them
	var/datum/browser/window = new/datum/browser(src, "discordverification", "Discord verification")
	window.set_content("<span>[message]</span>")
	window.open()

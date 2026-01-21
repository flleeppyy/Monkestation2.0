// Ported from Iris Station, with some modifications
#define US_EAST_RELAY_ADDR "byond://useast.monkestation.com:[world.port]"
#define WARSAW_RELAY_ADDR "byond://warsaw.monkestation.com:[world.port]"
#define NO_RELAY_ADDR "byond://play.monkestation.com:[world.port]"

#define US_EAST_RELAY "Connect to US-East (Ashburn)"
#define WARSAW_RELAY "Connect to Warsaw (Poland)"
#define NO_RELAY "No Relay (Direct Connect)"

/client/verb/go2relay()
	if(is_localhost())
		to_chat(usr, span_notice("You are on localhost, this verb is useless to you."))
		return
	var/list/static/relays = list(
		US_EAST_RELAY,
		WARSAW_RELAY,
		NO_RELAY,
	)
	var/list/static/relays_quickname = list(
		US_EAST_RELAY = replacetext(US_EAST_RELAY, "Connect to ", ""),
		WARSAW_RELAY = replacetext(WARSAW_RELAY, "Connect to ", ""),
		NO_RELAY = "Monke Direct",
	)
	var/choice = tgui_input_list(usr, "Which relay do you wish to use? Relays can help improve ping for some users.", "Relay Select", relays)
	var/destination
	switch(choice)
		if(US_EAST_RELAY)
			destination = US_EAST_RELAY_ADDR
		if(WARSAW_RELAY)
			destination = WARSAW_RELAY_ADDR
		if(NO_RELAY)
			destination = NO_RELAY_ADDR
	if(destination)
		to_chat_immediate(
			target = usr,
			html = boxed_message(span_info(span_big("Connecting you to [relays_quickname[choice]]\nIf nothing happens, try manually connecting to the relay ([destination]), or the RELAY may be down!"))),
			type = MESSAGE_TYPE_INFO,
		)
		usr << link(destination)

		// sleep(1 SECONDS)
		// winset(usr, null, "command=.quit")
	else
		to_chat(usr, span_notice("You didn't select a relay."))

#undef US_EAST_RELAY_ADDR
#undef WARSAW_RELAY_ADDR
#undef NO_RELAY_ADDR

#undef US_EAST_RELAY
#undef WARSAW_RELAY
#undef NO_RELAY

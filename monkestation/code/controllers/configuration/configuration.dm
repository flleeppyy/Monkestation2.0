/datum/controller/configuration/LoadMOTD()
	. = ..()

	if (text2num(rustg_unix_timestamp()) < 1736064000)
		motd = motd + "[motd]<br>" + "<span class='red big'>Monkestation admins are <span class='bold'>NO LONGER</span> accepting appeals for permanent bans until <span class='notice'>January 5th, 2025</span></span><br><hr><span class='yellowteamradio big'>Any permanent ban appeals made before said date will be <span class='bold red'>AUTOMATICALLY DENIED!</span></span><br><span class='big notice'>So don't get caught doing something stupid, ya hear?</span>"

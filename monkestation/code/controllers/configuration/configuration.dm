/datum/controller/configuration/LoadMOTD()
	. = ..()

	var/cur_day = text2num(time2text(world.realtime, "DD", "PT"))
	var/cur_mon = text2num(time2text(world.realtime, "MM", "PT"))
	var/cur_year = text2num(time2text(world.realtime, "YYYY", "PT"))

	if (!compare_dates(cur_year, cur_mon, cur_day, 2025, 1, 15))
		motd = motd + "[motd]<br>" + "<span class='red big'>Monkestation admins are <span class='bold'>NO LONGER</span> accepting appeals for permanent bans until <span class='notice'>January 15th, 2025</span></span><br><hr><span class='yellowteamradio big'>Any permanent ban appeals made before said date will be <span class='bold red'>AUTOMATICALLY DENIED!</span></span><br><span class='big notice'>So don't get caught doing something stupid, ya hear?</span>"

/proc/compare_dates(year1, month1, day1, year2, month2, day2)
		// TRUE if date1 >= date2, FALSE if date1 < date2
    var/comparable_date1 = year1 * 10000 + month1 * 100 + day1
    var/comparable_date2 = year2 * 10000 + month2 * 100 + day2

    return comparable_date1 >= comparable_date2

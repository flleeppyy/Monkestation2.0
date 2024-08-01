/obj/machinery/microwave
	var/dont_eject_after_done = FALSE
	var/can_eject = TRUE

/obj/machinery/microwave/eject(force = FALSE)
	if (!can_eject && !force)
		return
	. = ..()

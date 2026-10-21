// deconstruction hint for (tiny) fans
/obj/structure/fans/examine(mob/user)
	. += ..()
	. += span_notice("You can see the [EXAMINE_HINT("bolts")] holding it together.")

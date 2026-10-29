/mob/living/silicon/ai/Login()
	. = ..()
	// PAW EDIT ADDITION START - AI_LAW_PICKER
	if(!law_picker_offered)
		law_picker_offered = TRUE
		INVOKE_ASYNC(src, PROC_REF(ai_law_picker)) // requires a mind & client hence it being so late
	// PAW EDIT ADDITION END - AI_LAW_PICKER

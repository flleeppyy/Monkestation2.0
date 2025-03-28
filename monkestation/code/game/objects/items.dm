/obj/item
	/// If specified, the pickup sound will use this mixer channel.
	var/pickup_mixer_channel = CHANNEL_SOUND_EFFECTS
	/// If specified, the drop sound will use this mixer channel.
	var/drop_mixer_channel = CHANNEL_SOUND_EFFECTS
	/// If specified, the equip sound will use this mixer channel.
	var/equip_mixer_channel = CHANNEL_SOUND_EFFECTS

/obj/item/proc/adjust_weight_class(amt, min_weight = WEIGHT_CLASS_TINY, max_weight = WEIGHT_CLASS_GIGANTIC)
	if(!amt || !isnum(amt))
		stack_trace("Attempted to adjust weight class by an invalid value ([amt])")
		return FALSE
	var/old_w_class = w_class
	w_class = clamp(w_class + amt, min_weight, max_weight)
	return w_class != old_w_class

// SLIME_RANCHER - swaps slimecore's xenobio gear for the slime rancher's
/datum/techweb_node/bio_process/New()
	design_ids -= list(
		"corral_corner",
		"slime_extract_requestor",
		"slime_market_pad",
		"slime_market",
		"slimevac",
		"slime_compressor",
	)
	design_ids |= list(
		"extract_compressor",
		"slime_pen_post",
		"slime_rancher_scanner",
		"vacuum_pack",
		"vacuum_upgrade_printer",
	)
	return ..()

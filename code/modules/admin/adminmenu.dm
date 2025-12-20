/datum/verbs/menu/Admin/Generate_list(client/C)
	if (check_rights_for(C, R_ADMIN))
		. = ..()

/datum/verbs/menu/Admin/verb/Adminhelp()
	set desc = "Adminhelp"
	set name = "Open a ticket to admins."

	usr.client.adminhelp()

ADMIN_VERB(playerpanel, NONE, FALSE, "Player Panel", "Old TGUI player panel.", ADMIN_CATEGORY_GAME)
	user.holder.player_panel_new()
	BLACKBOX_LOG_ADMIN_VERB("Player Panel New")

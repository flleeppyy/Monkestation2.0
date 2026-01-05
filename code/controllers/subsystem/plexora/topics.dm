

#define TOPIC_EMITTER \
	if (input["emitter_token"]) { \
		INVOKE_ASYNC(SSplexora, TYPE_PROC_REF(/datum/controller/subsystem/plexora, topic_listener_response), input["emitter_token"], returning); \
		return; \
	};

/datum/world_topic/plx_announce
	keyword = "PLX_announce"
	require_comms_key = TRUE

/datum/world_topic/plx_announce/Run(list/input)
	var/message = input["message"]
	var/from = input["from"]

	send_formatted_announcement(message, "From [from]")

/datum/world_topic/plx_restartcontroller
	keyword = "PLX_restartcontroller"
	require_comms_key = TRUE

/datum/world_topic/plx_restartcontroller/Run(list/input)
	var/controller = input["controller"]
	var/username = input["username"]
	var/userid = input["userid"]

	if (!controller)
		return

	switch(LOWER_TEXT(controller))
		if("master")
			Recreate_MC()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "PLX: Restart Master Controller")
		if("failsafe")
			new /datum/controller/failsafe()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "PLX: Restart Failsafe Controller")
	message_admins("PLEXORA: @[username] ([userid]) has restarted the [controller] controller from the Discord.")


/datum/world_topic/plx_globalnarrate
	keyword = "PLX_globalnarrate"
	require_comms_key = TRUE

/datum/world_topic/plx_globalnarrate/Run(list/input)
	var/message = input["contents"]

	for(var/mob/player as anything in GLOB.player_list)
		to_chat(player, message)

/datum/world_topic/plx_who
	keyword = "PLX_who"
	require_comms_key = TRUE

/datum/world_topic/plx_who/Run(list/input)
	. = list()
	for(var/client/client as anything in GLOB.clients)
		if(QDELETED(client))
			continue
		. += list(list("key" = client.holder?.fakekey || client.key, "avgping" = "[round(client.avgping, 1)]ms"))

/datum/world_topic/plx_adminwho
	keyword = "PLX_adminwho"
	require_comms_key = TRUE

/datum/world_topic/plx_adminwho/Run(list/input)
	. = list()
	for (var/client/admin as anything in GLOB.admins)
		if(QDELETED(admin))
			continue
		var/admin_info = list(
			"name" = admin,
			"ckey" = admin.ckey,
			"rank" = admin.holder.rank_names(),
			"afk" = admin.is_afk(),
			"stealth" = !!admin.holder.fakekey,
			"stealthkey" = admin.holder.fakekey,
		)

		if(isobserver(admin.mob))
			admin_info["state"] = "observing"
		else if(isnewplayer(admin.mob))
			admin_info["state"] = "lobby"
		else
			admin_info["state"] = "playing"

		. += LIST_VALUE_WRAP_LISTS(admin_info)

/datum/world_topic/plx_mentorwho
	keyword = "PLX_mentorwho"
	require_comms_key = TRUE

/datum/world_topic/plx_mentorwho/Run(list/input)
	. = list()
	for (var/client/mentor as anything in GLOB.mentors)
		if(QDELETED(mentor))
			continue
		var/list/mentor_info = list(
			"name" = mentor,
			"ckey" = mentor.ckey,
			"rank" = mentor.holder?.rank_names(),
			"afk" = mentor.is_afk(),
			"stealth" = !!mentor.holder?.fakekey,
			"stealthkey" = mentor.holder?.fakekey,
		)

		if(isobserver(mentor.mob))
			mentor_info["state"] = "observing"
		else if(isnewplayer(mentor.mob))
			mentor_info["state"] = "lobby"
		else
			mentor_info["state"] = "playing"

		. += LIST_VALUE_WRAP_LISTS(mentor_info)

/datum/world_topic/plx_getloadoutrewards
	keyword = "PLX_getloadoutrewards"
	require_comms_key = FALSE

/datum/store_item/uwuuwu
	name = "meow"
	item_path = /obj/item/fish_analyzer

/datum/store_item/uwuuwu/bweh1
/datum/store_item/uwuuwu/bweh2
/datum/store_item/uwuuwu/bweh3
/datum/store_item/uwuuwu/bweh4
/datum/store_item/uwuuwu/bweh5
/datum/store_item/uwuuwu/bweh6
/datum/store_item/uwuuwu/bweh7
/datum/store_item/uwuuwu/bweh8
/datum/store_item/uwuuwu/bweh9
/datum/store_item/uwuuwu/bweh10
/datum/store_item/uwuuwu/bweh11
/datum/store_item/uwuuwu/bweh12
/datum/store_item/uwuuwu/bweh13
/datum/store_item/uwuuwu/bweh14
/datum/store_item/uwuuwu/bweh15
/datum/store_item/uwuuwu/bweh16
/datum/store_item/uwuuwu/bweh17
/datum/store_item/uwuuwu/bweh18
/datum/store_item/uwuuwu/bweh19
/datum/store_item/uwuuwu/bweh20
/datum/store_item/uwuuwu/bweh21
/datum/store_item/uwuuwu/bweh22
/datum/store_item/uwuuwu/bweh23
/datum/store_item/uwuuwu/bweh24
/datum/store_item/uwuuwu/bweh25
/datum/store_item/uwuuwu/bweh26
/datum/store_item/uwuuwu/bweh27
/datum/store_item/uwuuwu/bweh28
/datum/store_item/uwuuwu/bweh29
/datum/store_item/uwuuwu/bweh30
/datum/store_item/uwuuwu/bweh31
/datum/store_item/uwuuwu/bweh32
/datum/store_item/uwuuwu/bweh33
/datum/store_item/uwuuwu/bweh34
/datum/store_item/uwuuwu/bweh35
/datum/store_item/uwuuwu/bweh36
/datum/store_item/uwuuwu/bweh37
/datum/store_item/uwuuwu/bweh38
/datum/store_item/uwuuwu/bweh39
/datum/store_item/uwuuwu/bweh40
/datum/store_item/uwuuwu/bweh41
/datum/store_item/uwuuwu/bweh42
/datum/store_item/uwuuwu/bweh43
/datum/store_item/uwuuwu/bweh44
/datum/store_item/uwuuwu/bweh45
/datum/store_item/uwuuwu/bweh46
/datum/store_item/uwuuwu/bweh47
/datum/store_item/uwuuwu/bweh48
/datum/store_item/uwuuwu/bweh49
/datum/store_item/uwuuwu/bweh50
/datum/store_item/uwuuwu/bweh51
/datum/store_item/uwuuwu/bweh52
/datum/store_item/uwuuwu/bweh53
/datum/store_item/uwuuwu/bweh54
/datum/store_item/uwuuwu/bweh55
/datum/store_item/uwuuwu/bweh56
/datum/store_item/uwuuwu/bweh57
/datum/store_item/uwuuwu/bweh58
/datum/store_item/uwuuwu/bweh59
/datum/store_item/uwuuwu/bweh60
/datum/store_item/uwuuwu/bweh61
/datum/store_item/uwuuwu/bweh62
/datum/store_item/uwuuwu/bweh63
/datum/store_item/uwuuwu/bweh64
/datum/store_item/uwuuwu/bweh65
/datum/store_item/uwuuwu/bweh66
/datum/store_item/uwuuwu/bweh67
/datum/store_item/uwuuwu/bweh68
/datum/store_item/uwuuwu/bweh69
/datum/store_item/uwuuwu/bweh70
/datum/store_item/uwuuwu/bweh71
/datum/store_item/uwuuwu/bweh72
/datum/store_item/uwuuwu/bweh73
/datum/store_item/uwuuwu/bweh74
/datum/store_item/uwuuwu/bweh75
/datum/store_item/uwuuwu/bweh76
/datum/store_item/uwuuwu/bweh77
/datum/store_item/uwuuwu/bweh78
/datum/store_item/uwuuwu/bweh79
/datum/store_item/uwuuwu/bweh80
/datum/store_item/uwuuwu/bweh81
/datum/store_item/uwuuwu/bweh82
/datum/store_item/uwuuwu/bweh83
/datum/store_item/uwuuwu/bweh84
/datum/store_item/uwuuwu/bweh85
/datum/store_item/uwuuwu/bweh86
/datum/store_item/uwuuwu/bweh87
/datum/store_item/uwuuwu/bweh88
/datum/store_item/uwuuwu/bweh89
/datum/store_item/uwuuwu/bweh90
/datum/store_item/uwuuwu/bweh91
/datum/store_item/uwuuwu/bweh92
/datum/store_item/uwuuwu/bweh93
/datum/store_item/uwuuwu/bweh94
/datum/store_item/uwuuwu/bweh95
/datum/store_item/uwuuwu/bweh96
/datum/store_item/uwuuwu/bweh97
/datum/store_item/uwuuwu/bweh98
/datum/store_item/uwuuwu/bweh99
/datum/store_item/uwuuwu/bweh100
/datum/store_item/uwuuwu/bweh101
/datum/store_item/uwuuwu/bweh102
/datum/store_item/uwuuwu/bweh103
/datum/store_item/uwuuwu/bweh104
/datum/store_item/uwuuwu/bweh105
/datum/store_item/uwuuwu/bweh106
/datum/store_item/uwuuwu/bweh107
/datum/store_item/uwuuwu/bweh108
/datum/store_item/uwuuwu/bweh109
/datum/store_item/uwuuwu/bweh110
/datum/store_item/uwuuwu/bweh111
/datum/store_item/uwuuwu/bweh112
/datum/store_item/uwuuwu/bweh113
/datum/store_item/uwuuwu/bweh114
/datum/store_item/uwuuwu/bweh115
/datum/store_item/uwuuwu/bweh116
/datum/store_item/uwuuwu/bweh117
/datum/store_item/uwuuwu/bweh118
/datum/store_item/uwuuwu/bweh119
/datum/store_item/uwuuwu/bweh120
/datum/store_item/uwuuwu/bweh121
/datum/store_item/uwuuwu/bweh122
/datum/store_item/uwuuwu/bweh123
/datum/store_item/uwuuwu/bweh124
/datum/store_item/uwuuwu/bweh125
/datum/store_item/uwuuwu/bweh126
/datum/store_item/uwuuwu/bweh127
/datum/store_item/uwuuwu/bweh128
/datum/store_item/uwuuwu/bweh129
/datum/store_item/uwuuwu/bweh130
/datum/store_item/uwuuwu/bweh131
/datum/store_item/uwuuwu/bweh132
/datum/store_item/uwuuwu/bweh133
/datum/store_item/uwuuwu/bweh134
/datum/store_item/uwuuwu/bweh135
/datum/store_item/uwuuwu/bweh136
/datum/store_item/uwuuwu/bweh137
/datum/store_item/uwuuwu/bweh138
/datum/store_item/uwuuwu/bweh139
/datum/store_item/uwuuwu/bweh140
/datum/store_item/uwuuwu/bweh141
/datum/store_item/uwuuwu/bweh142
/datum/store_item/uwuuwu/bweh143
/datum/store_item/uwuuwu/bweh144
/datum/store_item/uwuuwu/bweh145
/datum/store_item/uwuuwu/bweh146
/datum/store_item/uwuuwu/bweh147
/datum/store_item/uwuuwu/bweh148
/datum/store_item/uwuuwu/bweh149
/datum/store_item/uwuuwu/bweh150
/datum/store_item/uwuuwu/bweh151
/datum/store_item/uwuuwu/bweh152
/datum/store_item/uwuuwu/bweh153
/datum/store_item/uwuuwu/bweh154
/datum/store_item/uwuuwu/bweh155
/datum/store_item/uwuuwu/bweh156
/datum/store_item/uwuuwu/bweh157
/datum/store_item/uwuuwu/bweh158
/datum/store_item/uwuuwu/bweh159
/datum/store_item/uwuuwu/bweh160
/datum/store_item/uwuuwu/bweh161
/datum/store_item/uwuuwu/bweh162
/datum/store_item/uwuuwu/bweh163
/datum/store_item/uwuuwu/bweh164
/datum/store_item/uwuuwu/bweh165
/datum/store_item/uwuuwu/bweh166
/datum/store_item/uwuuwu/bweh167
/datum/store_item/uwuuwu/bweh168
/datum/store_item/uwuuwu/bweh169
/datum/store_item/uwuuwu/bweh170
/datum/store_item/uwuuwu/bweh171
/datum/store_item/uwuuwu/bweh172
/datum/store_item/uwuuwu/bweh173
/datum/store_item/uwuuwu/bweh174
/datum/store_item/uwuuwu/bweh175
/datum/store_item/uwuuwu/bweh176
/datum/store_item/uwuuwu/bweh177
/datum/store_item/uwuuwu/bweh178
/datum/store_item/uwuuwu/bweh179
/datum/store_item/uwuuwu/bweh180
/datum/store_item/uwuuwu/bweh181
/datum/store_item/uwuuwu/bweh182
/datum/store_item/uwuuwu/bweh183
/datum/store_item/uwuuwu/bweh184
/datum/store_item/uwuuwu/bweh185
/datum/store_item/uwuuwu/bweh186
/datum/store_item/uwuuwu/bweh187
/datum/store_item/uwuuwu/bweh188
/datum/store_item/uwuuwu/bweh189
/datum/store_item/uwuuwu/bweh190
/datum/store_item/uwuuwu/bweh191
/datum/store_item/uwuuwu/bweh192
/datum/store_item/uwuuwu/bweh193
/datum/store_item/uwuuwu/bweh194
/datum/store_item/uwuuwu/bweh195
/datum/store_item/uwuuwu/bweh196
/datum/store_item/uwuuwu/bweh197
/datum/store_item/uwuuwu/bweh198
/datum/store_item/uwuuwu/bweh199
/datum/store_item/uwuuwu/bweh200
/datum/store_item/uwuuwu/bweh201
/datum/store_item/uwuuwu/bweh202
/datum/store_item/uwuuwu/bweh203
/datum/store_item/uwuuwu/bweh204
/datum/store_item/uwuuwu/bweh205
/datum/store_item/uwuuwu/bweh206
/datum/store_item/uwuuwu/bweh207
/datum/store_item/uwuuwu/bweh208
/datum/store_item/uwuuwu/bweh209
/datum/store_item/uwuuwu/bweh210
/datum/store_item/uwuuwu/bweh211
/datum/store_item/uwuuwu/bweh212
/datum/store_item/uwuuwu/bweh213
/datum/store_item/uwuuwu/bweh214
/datum/store_item/uwuuwu/bweh215
/datum/store_item/uwuuwu/bweh216
/datum/store_item/uwuuwu/bweh217
/datum/store_item/uwuuwu/bweh218
/datum/store_item/uwuuwu/bweh219
/datum/store_item/uwuuwu/bweh220
/datum/store_item/uwuuwu/bweh221
/datum/store_item/uwuuwu/bweh222
/datum/store_item/uwuuwu/bweh223
/datum/store_item/uwuuwu/bweh224
/datum/store_item/uwuuwu/bweh225
/datum/store_item/uwuuwu/bweh226
/datum/store_item/uwuuwu/bweh227
/datum/store_item/uwuuwu/bweh228
/datum/store_item/uwuuwu/bweh229
/datum/store_item/uwuuwu/bweh230
/datum/store_item/uwuuwu/bweh231
/datum/store_item/uwuuwu/bweh232
/datum/store_item/uwuuwu/bweh233
/datum/store_item/uwuuwu/bweh234
/datum/store_item/uwuuwu/bweh235
/datum/store_item/uwuuwu/bweh236
/datum/store_item/uwuuwu/bweh237
/datum/store_item/uwuuwu/bweh238
/datum/store_item/uwuuwu/bweh239
/datum/store_item/uwuuwu/bweh240
/datum/store_item/uwuuwu/bweh241
/datum/store_item/uwuuwu/bweh242
/datum/store_item/uwuuwu/bweh243
/datum/store_item/uwuuwu/bweh244
/datum/store_item/uwuuwu/bweh245
/datum/store_item/uwuuwu/bweh246
/datum/store_item/uwuuwu/bweh247
/datum/store_item/uwuuwu/bweh248
/datum/store_item/uwuuwu/bweh249
/datum/store_item/uwuuwu/bweh250
/datum/store_item/uwuuwu/bweh251
/datum/store_item/uwuuwu/bweh252
/datum/store_item/uwuuwu/bweh253
/datum/store_item/uwuuwu/bweh254
/datum/store_item/uwuuwu/bweh255
/datum/store_item/uwuuwu/bweh256
/datum/store_item/uwuuwu/bweh257
/datum/store_item/uwuuwu/bweh258
/datum/store_item/uwuuwu/bweh259
/datum/store_item/uwuuwu/bweh260
/datum/store_item/uwuuwu/bweh261
/datum/store_item/uwuuwu/bweh262
/datum/store_item/uwuuwu/bweh263
/datum/store_item/uwuuwu/bweh264
/datum/store_item/uwuuwu/bweh265
/datum/store_item/uwuuwu/bweh266
/datum/store_item/uwuuwu/bweh267
/datum/store_item/uwuuwu/bweh268
/datum/store_item/uwuuwu/bweh269
/datum/store_item/uwuuwu/bweh270
/datum/store_item/uwuuwu/bweh271
/datum/store_item/uwuuwu/bweh272
/datum/store_item/uwuuwu/bweh273
/datum/store_item/uwuuwu/bweh274
/datum/store_item/uwuuwu/bweh275
/datum/store_item/uwuuwu/bweh276
/datum/store_item/uwuuwu/bweh277
/datum/store_item/uwuuwu/bweh278
/datum/store_item/uwuuwu/bweh279
/datum/store_item/uwuuwu/bweh280
/datum/store_item/uwuuwu/bweh281
/datum/store_item/uwuuwu/bweh282
/datum/store_item/uwuuwu/bweh283
/datum/store_item/uwuuwu/bweh284
/datum/store_item/uwuuwu/bweh285
/datum/store_item/uwuuwu/bweh286
/datum/store_item/uwuuwu/bweh287
/datum/store_item/uwuuwu/bweh288
/datum/store_item/uwuuwu/bweh289
/datum/store_item/uwuuwu/bweh290
/datum/store_item/uwuuwu/bweh291
/datum/store_item/uwuuwu/bweh292
/datum/store_item/uwuuwu/bweh293
/datum/store_item/uwuuwu/bweh294
/datum/store_item/uwuuwu/bweh295
/datum/store_item/uwuuwu/bweh296
/datum/store_item/uwuuwu/bweh297
/datum/store_item/uwuuwu/bweh298
/datum/store_item/uwuuwu/bweh299
/datum/store_item/uwuuwu/bweh300
/datum/store_item/uwuuwu/bweh301
/datum/store_item/uwuuwu/bweh302
/datum/store_item/uwuuwu/bweh303
/datum/store_item/uwuuwu/bweh304
/datum/store_item/uwuuwu/bweh305
/datum/store_item/uwuuwu/bweh306
/datum/store_item/uwuuwu/bweh307
/datum/store_item/uwuuwu/bweh308
/datum/store_item/uwuuwu/bweh309
/datum/store_item/uwuuwu/bweh310
/datum/store_item/uwuuwu/bweh311
/datum/store_item/uwuuwu/bweh312
/datum/store_item/uwuuwu/bweh313
/datum/store_item/uwuuwu/bweh314
/datum/store_item/uwuuwu/bweh315
/datum/store_item/uwuuwu/bweh316
/datum/store_item/uwuuwu/bweh317
/datum/store_item/uwuuwu/bweh318
/datum/store_item/uwuuwu/bweh319
/datum/store_item/uwuuwu/bweh320
/datum/store_item/uwuuwu/bweh321
/datum/store_item/uwuuwu/bweh322
/datum/store_item/uwuuwu/bweh323
/datum/store_item/uwuuwu/bweh324
/datum/store_item/uwuuwu/bweh325
/datum/store_item/uwuuwu/bweh326
/datum/store_item/uwuuwu/bweh327
/datum/store_item/uwuuwu/bweh328
/datum/store_item/uwuuwu/bweh329
/datum/store_item/uwuuwu/bweh330
/datum/store_item/uwuuwu/bweh331
/datum/store_item/uwuuwu/bweh332
/datum/store_item/uwuuwu/bweh333
/datum/store_item/uwuuwu/bweh334
/datum/store_item/uwuuwu/bweh335
/datum/store_item/uwuuwu/bweh336
/datum/store_item/uwuuwu/bweh337
/datum/store_item/uwuuwu/bweh338
/datum/store_item/uwuuwu/bweh339
/datum/store_item/uwuuwu/bweh340
/datum/store_item/uwuuwu/bweh341
/datum/store_item/uwuuwu/bweh342
/datum/store_item/uwuuwu/bweh343
/datum/store_item/uwuuwu/bweh344
/datum/store_item/uwuuwu/bweh345
/datum/store_item/uwuuwu/bweh346
/datum/store_item/uwuuwu/bweh347
/datum/store_item/uwuuwu/bweh348
/datum/store_item/uwuuwu/bweh349
/datum/store_item/uwuuwu/bweh350
/datum/store_item/uwuuwu/bweh351
/datum/store_item/uwuuwu/bweh352
/datum/store_item/uwuuwu/bweh353
/datum/store_item/uwuuwu/bweh354
/datum/store_item/uwuuwu/bweh355
/datum/store_item/uwuuwu/bweh356
/datum/store_item/uwuuwu/bweh357
/datum/store_item/uwuuwu/bweh358
/datum/store_item/uwuuwu/bweh359
/datum/store_item/uwuuwu/bweh360
/datum/store_item/uwuuwu/bweh361
/datum/store_item/uwuuwu/bweh362
/datum/store_item/uwuuwu/bweh363
/datum/store_item/uwuuwu/bweh364
/datum/store_item/uwuuwu/bweh365
/datum/store_item/uwuuwu/bweh366
/datum/store_item/uwuuwu/bweh367
/datum/store_item/uwuuwu/bweh368
/datum/store_item/uwuuwu/bweh369
/datum/store_item/uwuuwu/bweh370
/datum/store_item/uwuuwu/bweh371
/datum/store_item/uwuuwu/bweh372
/datum/store_item/uwuuwu/bweh373
/datum/store_item/uwuuwu/bweh374
/datum/store_item/uwuuwu/bweh375
/datum/store_item/uwuuwu/bweh376
/datum/store_item/uwuuwu/bweh377
/datum/store_item/uwuuwu/bweh378
/datum/store_item/uwuuwu/bweh379
/datum/store_item/uwuuwu/bweh380
/datum/store_item/uwuuwu/bweh381
/datum/store_item/uwuuwu/bweh382
/datum/store_item/uwuuwu/bweh383
/datum/store_item/uwuuwu/bweh384
/datum/store_item/uwuuwu/bweh385
/datum/store_item/uwuuwu/bweh386
/datum/store_item/uwuuwu/bweh387
/datum/store_item/uwuuwu/bweh388
/datum/store_item/uwuuwu/bweh389
/datum/store_item/uwuuwu/bweh390
/datum/store_item/uwuuwu/bweh391
/datum/store_item/uwuuwu/bweh392
/datum/store_item/uwuuwu/bweh393
/datum/store_item/uwuuwu/bweh394
/datum/store_item/uwuuwu/bweh395
/datum/store_item/uwuuwu/bweh396
/datum/store_item/uwuuwu/bweh397
/datum/store_item/uwuuwu/bweh398
/datum/store_item/uwuuwu/bweh399
/datum/store_item/uwuuwu/bweh400
/datum/store_item/uwuuwu/bweh401
/datum/store_item/uwuuwu/bweh402
/datum/store_item/uwuuwu/bweh403
/datum/store_item/uwuuwu/bweh404
/datum/store_item/uwuuwu/bweh405
/datum/store_item/uwuuwu/bweh406
/datum/store_item/uwuuwu/bweh407
/datum/store_item/uwuuwu/bweh408
/datum/store_item/uwuuwu/bweh409
/datum/store_item/uwuuwu/bweh410
/datum/store_item/uwuuwu/bweh411
/datum/store_item/uwuuwu/bweh412
/datum/store_item/uwuuwu/bweh413
/datum/store_item/uwuuwu/bweh414
/datum/store_item/uwuuwu/bweh415
/datum/store_item/uwuuwu/bweh416
/datum/store_item/uwuuwu/bweh417
/datum/store_item/uwuuwu/bweh418
/datum/store_item/uwuuwu/bweh419
/datum/store_item/uwuuwu/bweh420
/datum/store_item/uwuuwu/bweh421
/datum/store_item/uwuuwu/bweh422
/datum/store_item/uwuuwu/bweh423
/datum/store_item/uwuuwu/bweh424
/datum/store_item/uwuuwu/bweh425
/datum/store_item/uwuuwu/bweh426
/datum/store_item/uwuuwu/bweh427
/datum/store_item/uwuuwu/bweh428
/datum/store_item/uwuuwu/bweh429
/datum/store_item/uwuuwu/bweh430
/datum/store_item/uwuuwu/bweh431
/datum/store_item/uwuuwu/bweh432
/datum/store_item/uwuuwu/bweh433
/datum/store_item/uwuuwu/bweh434
/datum/store_item/uwuuwu/bweh435
/datum/store_item/uwuuwu/bweh436
/datum/store_item/uwuuwu/bweh437
/datum/store_item/uwuuwu/bweh438
/datum/store_item/uwuuwu/bweh439
/datum/store_item/uwuuwu/bweh440
/datum/store_item/uwuuwu/bweh441
/datum/store_item/uwuuwu/bweh442
/datum/store_item/uwuuwu/bweh443
/datum/store_item/uwuuwu/bweh444
/datum/store_item/uwuuwu/bweh445
/datum/store_item/uwuuwu/bweh446
/datum/store_item/uwuuwu/bweh447
/datum/store_item/uwuuwu/bweh448
/datum/store_item/uwuuwu/bweh449
/datum/store_item/uwuuwu/bweh450
/datum/store_item/uwuuwu/bweh451
/datum/store_item/uwuuwu/bweh452
/datum/store_item/uwuuwu/bweh453
/datum/store_item/uwuuwu/bweh454
/datum/store_item/uwuuwu/bweh455
/datum/store_item/uwuuwu/bweh456
/datum/store_item/uwuuwu/bweh457
/datum/store_item/uwuuwu/bweh458
/datum/store_item/uwuuwu/bweh459
/datum/store_item/uwuuwu/bweh460
/datum/store_item/uwuuwu/bweh461
/datum/store_item/uwuuwu/bweh462
/datum/store_item/uwuuwu/bweh463
/datum/store_item/uwuuwu/bweh464
/datum/store_item/uwuuwu/bweh465
/datum/store_item/uwuuwu/bweh466
/datum/store_item/uwuuwu/bweh467
/datum/store_item/uwuuwu/bweh468
/datum/store_item/uwuuwu/bweh469
/datum/store_item/uwuuwu/bweh470
/datum/store_item/uwuuwu/bweh471
/datum/store_item/uwuuwu/bweh472
/datum/store_item/uwuuwu/bweh473
/datum/store_item/uwuuwu/bweh474
/datum/store_item/uwuuwu/bweh475
/datum/store_item/uwuuwu/bweh476
/datum/store_item/uwuuwu/bweh477
/datum/store_item/uwuuwu/bweh478
/datum/store_item/uwuuwu/bweh479
/datum/store_item/uwuuwu/bweh480
/datum/store_item/uwuuwu/bweh481
/datum/store_item/uwuuwu/bweh482
/datum/store_item/uwuuwu/bweh483
/datum/store_item/uwuuwu/bweh484
/datum/store_item/uwuuwu/bweh485
/datum/store_item/uwuuwu/bweh486
/datum/store_item/uwuuwu/bweh487
/datum/store_item/uwuuwu/bweh488
/datum/store_item/uwuuwu/bweh489
/datum/store_item/uwuuwu/bweh490
/datum/store_item/uwuuwu/bweh491
/datum/store_item/uwuuwu/bweh492
/datum/store_item/uwuuwu/bweh493
/datum/store_item/uwuuwu/bweh494
/datum/store_item/uwuuwu/bweh495
/datum/store_item/uwuuwu/bweh496
/datum/store_item/uwuuwu/bweh497
/datum/store_item/uwuuwu/bweh498
/datum/store_item/uwuuwu/bweh499
/datum/store_item/uwuuwu/bweh500
/datum/store_item/uwuuwu/bweh501
/datum/store_item/uwuuwu/bweh502
/datum/store_item/uwuuwu/bweh503
/datum/store_item/uwuuwu/bweh504
/datum/store_item/uwuuwu/bweh505
/datum/store_item/uwuuwu/bweh506
/datum/store_item/uwuuwu/bweh507
/datum/store_item/uwuuwu/bweh508
/datum/store_item/uwuuwu/bweh509
/datum/store_item/uwuuwu/bweh510
/datum/store_item/uwuuwu/bweh511
/datum/store_item/uwuuwu/bweh512
/datum/store_item/uwuuwu/bweh513
/datum/store_item/uwuuwu/bweh514
/datum/store_item/uwuuwu/bweh515
/datum/store_item/uwuuwu/bweh516
/datum/store_item/uwuuwu/bweh517
/datum/store_item/uwuuwu/bweh518
/datum/store_item/uwuuwu/bweh519
/datum/store_item/uwuuwu/bweh520
/datum/store_item/uwuuwu/bweh521
/datum/store_item/uwuuwu/bweh522
/datum/store_item/uwuuwu/bweh523
/datum/store_item/uwuuwu/bweh524
/datum/store_item/uwuuwu/bweh525
/datum/store_item/uwuuwu/bweh526
/datum/store_item/uwuuwu/bweh527
/datum/store_item/uwuuwu/bweh528
/datum/store_item/uwuuwu/bweh529
/datum/store_item/uwuuwu/bweh530
/datum/store_item/uwuuwu/bweh531
/datum/store_item/uwuuwu/bweh532
/datum/store_item/uwuuwu/bweh533
/datum/store_item/uwuuwu/bweh534
/datum/store_item/uwuuwu/bweh535
/datum/store_item/uwuuwu/bweh536
/datum/store_item/uwuuwu/bweh537
/datum/store_item/uwuuwu/bweh538
/datum/store_item/uwuuwu/bweh539
/datum/store_item/uwuuwu/bweh540
/datum/store_item/uwuuwu/bweh541
/datum/store_item/uwuuwu/bweh542
/datum/store_item/uwuuwu/bweh543
/datum/store_item/uwuuwu/bweh544
/datum/store_item/uwuuwu/bweh545
/datum/store_item/uwuuwu/bweh546
/datum/store_item/uwuuwu/bweh547
/datum/store_item/uwuuwu/bweh548
/datum/store_item/uwuuwu/bweh549
/datum/store_item/uwuuwu/bweh550
/datum/store_item/uwuuwu/bweh551
/datum/store_item/uwuuwu/bweh552
/datum/store_item/uwuuwu/bweh553
/datum/store_item/uwuuwu/bweh554
/datum/store_item/uwuuwu/bweh555
/datum/store_item/uwuuwu/bweh556
/datum/store_item/uwuuwu/bweh557
/datum/store_item/uwuuwu/bweh558
/datum/store_item/uwuuwu/bweh559
/datum/store_item/uwuuwu/bweh560
/datum/store_item/uwuuwu/bweh561
/datum/store_item/uwuuwu/bweh562
/datum/store_item/uwuuwu/bweh563
/datum/store_item/uwuuwu/bweh564
/datum/store_item/uwuuwu/bweh565
/datum/store_item/uwuuwu/bweh566
/datum/store_item/uwuuwu/bweh567
/datum/store_item/uwuuwu/bweh568
/datum/store_item/uwuuwu/bweh569
/datum/store_item/uwuuwu/bweh570
/datum/store_item/uwuuwu/bweh571
/datum/store_item/uwuuwu/bweh572
/datum/store_item/uwuuwu/bweh573
/datum/store_item/uwuuwu/bweh574
/datum/store_item/uwuuwu/bweh575
/datum/store_item/uwuuwu/bweh576
/datum/store_item/uwuuwu/bweh577
/datum/store_item/uwuuwu/bweh578
/datum/store_item/uwuuwu/bweh579
/datum/store_item/uwuuwu/bweh580
/datum/store_item/uwuuwu/bweh581
/datum/store_item/uwuuwu/bweh582
/datum/store_item/uwuuwu/bweh583
/datum/store_item/uwuuwu/bweh584
/datum/store_item/uwuuwu/bweh585
/datum/store_item/uwuuwu/bweh586
/datum/store_item/uwuuwu/bweh587
/datum/store_item/uwuuwu/bweh588
/datum/store_item/uwuuwu/bweh589
/datum/store_item/uwuuwu/bweh590
/datum/store_item/uwuuwu/bweh591
/datum/store_item/uwuuwu/bweh592
/datum/store_item/uwuuwu/bweh593
/datum/store_item/uwuuwu/bweh594
/datum/store_item/uwuuwu/bweh595
/datum/store_item/uwuuwu/bweh596
/datum/store_item/uwuuwu/bweh597
/datum/store_item/uwuuwu/bweh598
/datum/store_item/uwuuwu/bweh599
/datum/store_item/uwuuwu/bweh600
/datum/store_item/uwuuwu/bweh601
/datum/store_item/uwuuwu/bweh602
/datum/store_item/uwuuwu/bweh603
/datum/store_item/uwuuwu/bweh604
/datum/store_item/uwuuwu/bweh605
/datum/store_item/uwuuwu/bweh606
/datum/store_item/uwuuwu/bweh607
/datum/store_item/uwuuwu/bweh608
/datum/store_item/uwuuwu/bweh609
/datum/store_item/uwuuwu/bweh610
/datum/store_item/uwuuwu/bweh611
/datum/store_item/uwuuwu/bweh612
/datum/store_item/uwuuwu/bweh613
/datum/store_item/uwuuwu/bweh614
/datum/store_item/uwuuwu/bweh615
/datum/store_item/uwuuwu/bweh616
/datum/store_item/uwuuwu/bweh617
/datum/store_item/uwuuwu/bweh618
/datum/store_item/uwuuwu/bweh619
/datum/store_item/uwuuwu/bweh620
/datum/store_item/uwuuwu/bweh621
/datum/store_item/uwuuwu/bweh622
/datum/store_item/uwuuwu/bweh623
/datum/store_item/uwuuwu/bweh624
/datum/store_item/uwuuwu/bweh625
/datum/store_item/uwuuwu/bweh626
/datum/store_item/uwuuwu/bweh627
/datum/store_item/uwuuwu/bweh628
/datum/store_item/uwuuwu/bweh629
/datum/store_item/uwuuwu/bweh630
/datum/store_item/uwuuwu/bweh631
/datum/store_item/uwuuwu/bweh632
/datum/store_item/uwuuwu/bweh633
/datum/store_item/uwuuwu/bweh634
/datum/store_item/uwuuwu/bweh635
/datum/store_item/uwuuwu/bweh636
/datum/store_item/uwuuwu/bweh637
/datum/store_item/uwuuwu/bweh638
/datum/store_item/uwuuwu/bweh639
/datum/store_item/uwuuwu/bweh640
/datum/store_item/uwuuwu/bweh641
/datum/store_item/uwuuwu/bweh642
/datum/store_item/uwuuwu/bweh643
/datum/store_item/uwuuwu/bweh644
/datum/store_item/uwuuwu/bweh645
/datum/store_item/uwuuwu/bweh646
/datum/store_item/uwuuwu/bweh647
/datum/store_item/uwuuwu/bweh648
/datum/store_item/uwuuwu/bweh649
/datum/store_item/uwuuwu/bweh650
/datum/store_item/uwuuwu/bweh651
/datum/store_item/uwuuwu/bweh652
/datum/store_item/uwuuwu/bweh653
/datum/store_item/uwuuwu/bweh654
/datum/store_item/uwuuwu/bweh655
/datum/store_item/uwuuwu/bweh656
/datum/store_item/uwuuwu/bweh657
/datum/store_item/uwuuwu/bweh658
/datum/store_item/uwuuwu/bweh659
/datum/store_item/uwuuwu/bweh660
/datum/store_item/uwuuwu/bweh661
/datum/store_item/uwuuwu/bweh662
/datum/store_item/uwuuwu/bweh663
/datum/store_item/uwuuwu/bweh664
/datum/store_item/uwuuwu/bweh665
/datum/store_item/uwuuwu/bweh666
/datum/store_item/uwuuwu/bweh667
/datum/store_item/uwuuwu/bweh668
/datum/store_item/uwuuwu/bweh669
/datum/store_item/uwuuwu/bweh670
/datum/store_item/uwuuwu/bweh671
/datum/store_item/uwuuwu/bweh672
/datum/store_item/uwuuwu/bweh673
/datum/store_item/uwuuwu/bweh674
/datum/store_item/uwuuwu/bweh675
/datum/store_item/uwuuwu/bweh676
/datum/store_item/uwuuwu/bweh677
/datum/store_item/uwuuwu/bweh678
/datum/store_item/uwuuwu/bweh679
/datum/store_item/uwuuwu/bweh680
/datum/store_item/uwuuwu/bweh681
/datum/store_item/uwuuwu/bweh682
/datum/store_item/uwuuwu/bweh683
/datum/store_item/uwuuwu/bweh684
/datum/store_item/uwuuwu/bweh685
/datum/store_item/uwuuwu/bweh686
/datum/store_item/uwuuwu/bweh687
/datum/store_item/uwuuwu/bweh688
/datum/store_item/uwuuwu/bweh689
/datum/store_item/uwuuwu/bweh690
/datum/store_item/uwuuwu/bweh691
/datum/store_item/uwuuwu/bweh692
/datum/store_item/uwuuwu/bweh693
/datum/store_item/uwuuwu/bweh694
/datum/store_item/uwuuwu/bweh695
/datum/store_item/uwuuwu/bweh696
/datum/store_item/uwuuwu/bweh697
/datum/store_item/uwuuwu/bweh698
/datum/store_item/uwuuwu/bweh699

/datum/world_topic/plx_getloadoutrewards/Run(list/input)
	var/list/typelist = list()
	for(var/datum/store_item/store_item as anything in subtypesof(/datum/store_item) - typesof(/datum/store_item/roundstart))
		if(!store_item::name || !store_item::item_path)
			continue
		typelist += store_item

	return typelist

/datum/world_topic/plx_getunusualitems
	keyword = "PLX_getunusualitems"
	require_comms_key = TRUE

/datum/world_topic/plx_getunusualitems/Run(list/input)
	return GLOB.possible_lootbox_clothing

/datum/world_topic/get_unusualeffects
	keyword = "PLX_getunusualeffects"
	require_comms_key = TRUE

/datum/world_topic/get_unusualeffects/Run(list/input)
	return subtypesof(/datum/component/particle_spewer) - /datum/component/particle_spewer/movement

/datum/world_topic/plx_getsmites
	keyword = "PLX_getsmites"
	require_comms_key = TRUE

/datum/world_topic/plx_getsmites/Run(list/input)
	. = list()
	for (var/datum/smite/smite_path as anything in subtypesof(/datum/smite))
		var/smite_name = smite_path::name
		if(!smite_name)
			continue
		try
			var/datum/smite/smite_instance = new smite_path
			if (smite_instance.configure(new /datum/client_interface("fake_player")) == "NO_CONFIG")
				.[smite_name] = smite_path
			QDEL_NULL(smite_instance)
		catch
			pass()

/datum/world_topic/plx_gettwitchevents
	keyword = "PLX_gettwitchevents"
	require_comms_key = TRUE

/datum/world_topic/plx_gettwitchevents/Run(list/input)
	. = list()
	for (var/datum/twitch_event/event_path as anything in subtypesof(/datum/twitch_event))
		.[event_path::event_name] = event_path::id_tag

/datum/world_topic/plx_getbasicplayerdetails
	keyword = "PLX_getbasicplayerdetails"
	require_comms_key = TRUE

/datum/world_topic/plx_getbasicplayerdetails/Run(list/input)
	var/ckey = input["ckey"]

	if (!ckey)
		return list("error" = PLEXORA_ERROR_MISSING_CKEY)

	var/list/returning = list(
		"ckey" = ckey
	)

	var/client/client = disambiguate_client(ckey)

	if (QDELETED(client))
		returning["present"] = FALSE
	else
		returning["present"] = TRUE
		returning["key"] = client.key

	var/datum/persistent_client/details = GLOB.persistent_clients_by_ckey[ckey]

	if (details)
		returning["byond_version"] = details.byond_version

	if (QDELETED(client))
		var/datum/client_interface/mock_player = new(ckey)
		mock_player.prefs = new /datum/preferences(mock_player)
		returning["playtime"] = mock_player.get_exp_living(FALSE)
	else
		returning["playtime"] = client.get_exp_living(FALSE)

	return returning

/datum/world_topic/plx_getplayerdetails
	keyword = "PLX_getplayerdetails"
	require_comms_key = TRUE

/datum/world_topic/plx_getplayerdetails/Run(list/input)
	var/ckey = input["ckey"]
	var/omit_logs = input["omit_logs"]

	if (!ckey)
		return list("error" = PLEXORA_ERROR_MISSING_CKEY)

	var/datum/persistent_client/details = GLOB.persistent_clients_by_ckey[ckey]

	if (QDELETED(details))
		return list("error" = PLEXORA_ERROR_DETAILSNOTEXIST)

	var/client/client = disambiguate_client(ckey)

	var/list/returning = list(
		"ckey" = ckey,
		"present" = !QDELETED(client),
		"admin_datum" = null,
		"logging" = details.logging,
		"played_names" = details.played_names,
		"byond_version" = details.byond_version,
		"achievements" = details.achievements.data,
	)

	var/mob/clientmob
	if (!QDELETED(client))
		returning["playtime"] = client.get_exp_living(FALSE)
		returning["key"] = client.key
		clientmob = client.mob
	else
		for (var/mob/mob as anything in GLOB.mob_list)
			if (!QDELETED(mob) && mob.ckey == ckey)
				clientmob = mob
				break

	if (!omit_logs)
		returning["logging"] = details.logging

	if (GLOB.admin_datums[ckey])
		var/datum/admins/ckeyadatum = GLOB.admin_datums[ckey]
		returning["admin_datum"] = list(
			"name" = ckeyadatum.name,
			"ranks" = ckeyadatum.get_ranks(),
			"fakekey" = ckeyadatum.fakekey,
			"deadmined" = ckeyadatum.deadmined,
			"bypass_2fa" = ckeyadatum.bypass_2fa,
			"admin_signature" = ckeyadatum.admin_signature,
		)

	if (!QDELETED(clientmob))
		returning["mob"] = list(
			"name" = clientmob.name,
			"real_name" = clientmob.real_name,
			"type" = clientmob.type,
			"gender" = clientmob.gender,
			"stat" = clientmob.stat,
		)

	if (!QDELETED(client) && isliving(clientmob))
		var/mob/living/livingmob = clientmob
		returning["health"] = livingmob.health
		returning["maxHealth"] = livingmob.maxHealth
		returning["bruteloss"] = livingmob.bruteloss
		returning["fireloss"] = livingmob.fireloss
		returning["toxloss"] = livingmob.toxloss
		returning["oxyloss"] = livingmob.oxyloss

	TOPIC_EMITTER

	return returning

/datum/world_topic/plx_mobpicture
	keyword = "PLX_mobpicture"
	require_comms_key = TRUE

/datum/world_topic/plx_mobpicture/Run(list/input)
	var/ckey = input["ckey"]

	if (!ckey)
		return list("error" = PLEXORA_ERROR_MISSING_CKEY)

	var/client/client = disambiguate_client(ckey)

	if (QDELETED(client))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	var/returning = list(
		"icon_b64" = icon2base64(getFlatIcon(client.mob, no_anim = TRUE))
	)

	TOPIC_EMITTER

	return returning

/datum/world_topic/plx_generategiveawaycodes
	keyword = "PLX_generategiveawaycodes"
	require_comms_key = TRUE

/datum/world_topic/plx_generategiveawaycodes/Run(list/input)
	var/type = input["type"]
	var/codeamount = input["limit"]

	. = list()

	if (type == "loadout" && !input["loadout"])
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "loadout", "reason" = "loadout type codes require a loadout parameter")

	for (var/i in 1 to codeamount)
		var/returning = list("type" = type)

		switch(type)
			if ("coin")
				var/amount = input["coins"]
				if (isnull(amount))
					amount = 5000
				returning["coins"] = amount
				returning["code"] = generate_coin_code(amount, TRUE)
			if ("loadout")
				var/loadout = input["loadout"]
				//we are not chosing a random one for this, you MUST specify
				if (!loadout) return
				returning["loadout"] = loadout
				returning["code"] = generate_loadout_code(loadout, TRUE)
			if ("antagtoken")
				var/tokentype = input["antagtoken"]
				if (!tokentype)
					tokentype = LOW_THREAT
				returning["antagtoken"] = tokentype
				returning["code"] = generate_antag_token_code(tokentype, TRUE)
			if ("unusual")
				var/item = input["unusual_item"]
				var/effect = input["unusual_effect"]
				if (!item)
					item = pick(GLOB.possible_lootbox_clothing)
				if (!effect)
					var/static/list/possible_effects = subtypesof(/datum/component/particle_spewer) - /datum/component/particle_spewer/movement
					effect = pick(possible_effects)
				returning["item"] = item
				returning["effect"] = effect
				returning["code"] = generate_unusual_code(item, effect, TRUE)

		. += list(returning)

/datum/world_topic/plx_givecoins
	keyword = "PLX_givecoins"
	require_comms_key = TRUE

/datum/world_topic/plx_givecoins/Run(list/input)
	var/ckey = input["ckey"]
	var/amount = input["amount"]
	var/reason = input["reason"]

	amount = text2num(amount)
	if (!amount)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "amount", "reason" = "parameter must be a number greater than 0")

	if(!ckey)
		return list("error" = PLEXORA_ERROR_MISSING_CKEY)

	var/client/userclient = disambiguate_client(ckey)

	var/datum/preferences/prefs
	if (QDELETED(userclient))
		var/datum/client_interface/mock_player = new(ckey)
		mock_player.prefs = new /datum/preferences(mock_player)

		prefs = mock_player.prefs
	else
		prefs = userclient.prefs

	prefs.adjust_metacoins(ckey, amount, reason, donator_multiplier = FALSE, respects_roundcap = FALSE, announces = FALSE)

	return list("totalcoins" = prefs.metacoins)


/datum/world_topic/plx_forceemote
	keyword = "PLX_forceemote"
	require_comms_key = TRUE

/datum/world_topic/plx_forceemote/Run(list/input)
	var/target_ckey = input["ckey"]
	var/emote = input["emote"]
	var/emote_args = input["emote_args"]

	if(!target_ckey || !emote)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "ckey/emote", "reason" = "missing required parameter")

	var/client/client = disambiguate_client(ckey(target_ckey))

	if (QDELETED(client))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	var/mob/client_mob = client.mob

	if (QDELETED(client_mob))
		return list("error" = PLEXORA_ERROR_CLIENTNOMOB)

	return list(
		"success" = client_mob.emote(emote, message = emote_args, intentional = FALSE)
	)

/datum/world_topic/plx_forcesay
	keyword = "PLX_forcesay"
	require_comms_key = TRUE

/datum/world_topic/plx_forcesay/Run(list/input)
	var/target_ckey = input["ckey"]
	var/message = input["message"]

	if(!target_ckey || !message)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "ckey/message", "reason" = "missing required parameter")

	var/client/client = disambiguate_client(ckey(target_ckey))

	if (QDELETED(client))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	var/mob/client_mob = client.mob

	if (QDELETED(client_mob))
		return list("error" = PLEXORA_ERROR_CLIENTNOMOB)

	client_mob.say(message, forced = TRUE)

/datum/world_topic/plx_runtwitchevent
	keyword = "plx_runtwitchevent"
	require_comms_key = TRUE

/datum/world_topic/plx_runtwitchevent/Run(list/input)
	var/event = input["event"]
	// TODO: do something with the executor input
	//var/executor = input["executor"]


	if (!CONFIG_GET(string/twitch_key))
		return list("error" = PLEXORA_ERROR_NOTWITCHKEY)

	if(!event)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "event", "reason" = "missing required parameter")

	// cant be bothered, lets just call the topic.
	var/outgoing = list("TWITCH-API", CONFIG_GET(string/twitch_key), event,)
	SStwitch.handle_topic(outgoing)

/datum/world_topic/plx_smite
	keyword = "PLX_smite"
	require_comms_key = TRUE

/datum/world_topic/plx_smite/Run(list/input)
	var/target_ckey = input["ckey"]
	var/selected_smite = input["smite"]
	var/smited_by = input["smited_by_ckey"]

	if(!target_ckey || !selected_smite || !smited_by)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "ckey/smite/smited_by_ckey", "reason" = "missing required parameter")

	if (!GLOB.smites[selected_smite])
		return list("error" = PLEXORA_ERROR_INVALIDSMITE)

	var/client/client = disambiguate_client(target_ckey)

	if (QDELETED(client))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	// DIVINE SMITING!
	var/smite_path = GLOB.smites[selected_smite]
	var/datum/smite/picking_smite = new smite_path
	var/configuration_success = picking_smite.configure(client)
	if (configuration_success == FALSE)
		return

	// Mock admin
	var/datum/client_interface/mockadmin = new(key = smited_by)

	usr = mockadmin
	picking_smite.effect(client, client.mob)

/datum/world_topic/plx_jailmob
	keyword = "PLX_jailmob"
	require_comms_key = TRUE

/datum/world_topic/plx_jailmob/Run(list/input)
	var/ckey = input["ckey"]
	var/jailer = input["admin_ckey"]

	if(!ckey || !jailer)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "ckey/admin_ckey", "reason" = "missing required parameter")

	var/client/client = disambiguate_client(ckey)

	if (QDELETED(client))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	var/mob/client_mob = client.mob

	if (QDELETED(client_mob))
		return list("error" = PLEXORA_ERROR_CLIENTNOMOB)

	// Mock admin
	var/datum/client_interface/mockadmin = new(
		key = jailer,
	)

	usr = mockadmin

	client_mob.forceMove(pick(GLOB.prisonwarp))
	to_chat(client_mob, span_adminnotice("You have been sent to Prison!"), confidential = TRUE)

	log_admin("Discord: [key_name(usr)] has sent [key_name(client_mob)] to Prison!")
	message_admins("Discord: [key_name_admin(usr)] has sent [key_name_admin(client_mob)] to Prison!")

/datum/world_topic/plx_ticketaction
	keyword = "PLX_ticketaction"
	require_comms_key = TRUE

/datum/world_topic/plx_ticketaction/Run(list/input)
	var/ticketid = input["id"]
	var/action_by_ckey = input["action_by"]
	var/action = input["action"]

	if(!ticketid || !action_by_ckey || !action)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "id/action_by/action", "reason" = "missing required parameter")

	var/datum/client_interface/mockadmin = new(key = action_by_ckey)

	usr = mockadmin

	var/datum/admin_help/ticket = GLOB.ahelp_tickets.TicketByID(ticketid)
	if (QDELETED(ticket)) return list("error" = PLEXORA_ERROR_TICKETNOTEXIST)

	if (action != "reopen" && ticket.state != AHELP_ACTIVE)
		return

	switch(action)
		if("reopen")
			if (ticket.state == AHELP_ACTIVE) return
			SSplexora.aticket_reopened(ticket, action_by_ckey)
			ticket.Reopen()
		if("reject")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_REJECT)
			ticket.Reject(action_by_ckey)
		if("icissue")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_RESOLVE, AHELP_CLOSEREASON_IC)
			ticket.ICIssue(action_by_ckey)
		if("close")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_CLOSE)
			ticket.Close(action_by_ckey)
		if("resolve")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_RESOLVE)
			ticket.Resolve(action_by_ckey)
		if("mhelp")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_CLOSE, AHELP_CLOSEREASON_MENTOR)
			ticket.MHelpThis(action_by_ckey)

/datum/world_topic/plx_sendaticketpm
	keyword = "PLX_sendaticketpm"
	require_comms_key = TRUE

/datum/world_topic/plx_sendaticketpm/Run(list/input)
	// We're kind of copying /proc/TgsPm here...
	var/ticketid = text2num(input["ticket_id"])
	var/input_ckey = input["ckey"]
	var/sender = input["sender_ckey"]
	var/stealth = input["stealth"]
	var/message = input["message"]

	if(!input_ckey || !sender || !message)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "ckey/sender_ckey/message", "reason" = "missing required parameter")

	var/requested_ckey = ckey(input_ckey)
	var/client/recipient = disambiguate_client(requested_ckey)

	if (QDELETED(recipient))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	var/datum/admin_help/ticket = ticketid ? GLOB.ahelp_tickets.TicketByID(ticketid) : GLOB.ahelp_tickets.CKey2ActiveTicket(requested_ckey)

	if (QDELETED(ticket))
		return list("error" = PLEXORA_ERROR_TICKETNOTEXIST)

	var/plx_tagged = "[sender]"

	var/adminname = stealth ? "Administrator" : plx_tagged
	var/stealthkey = GetTgsStealthKey()

	message = sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN))
	message = emoji_parse(message)

	if (!message)
		return list("error" = PLEXORA_ERROR_SANITIZATION_FAILED)

	// I have no idea what this does honestly.


	// The ckey of our recipient, with a reply link, and their mob if one exists
	var/recipient_name_linked = key_name_admin(recipient)
	// The ckey of our recipient, with their mob if one exists. No link
	var/recipient_name = key_name_admin(recipient)

	message_admins("External message from [sender] to [recipient_name_linked] : [message]")
	log_admin_private("External PM: [sender] -> [recipient_name] : [message]")

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>",
		confidential = TRUE)

	recipient.receive_ahelp(
		"<a href='byond://?priv_msg=[stealthkey]'>[adminname]</a>",
		message,
	)

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("<i>Click on the administrator's name to reply.</i>"),
		confidential = TRUE)

	ticket.AddInteraction(message, ckey=sender)

	window_flash(recipient, ignorepref = TRUE)
	// Nullcheck because we run a winset in window flash and I do not trust byond
	if(!QDELETED(recipient))
		//always play non-admin recipients the adminhelp sound
		SEND_SOUND(recipient, 'sound/effects/adminhelp.ogg')

		recipient.externalreplyamount = EXTERNALREPLYCOUNT

/datum/world_topic/plx_sendmticketpm
	keyword = "PLX_sendmticketpm"
	require_comms_key = TRUE

/datum/world_topic/plx_sendmticketpm/Run(list/input)
	//var/ticketid = input["ticket_id"]
	var/target_ckey = input["ckey"]
	var/sender = input["sender_ckey"]
	var/message = input["message"]

	if(!target_ckey || !sender || !message)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "ckey/sender_ckey/message", "reason" = "missing required parameter")

	var/client/recipient = disambiguate_client(ckey(target_ckey))

	if (QDELETED(recipient))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	// var/datum/request/request = GLOB.mentor_requests.requests_by_id[num2text(ticketid)]

	SEND_SOUND(recipient, 'sound/items/bikehorn.ogg')
	to_chat(recipient, "<font color='purple'>Mentor PM from-<b>[key_name_mentor(sender, recipient, TRUE, FALSE, FALSE)]</b>: [message]</font>")
	for(var/client/honked_client as anything in GLOB.mentors | GLOB.admins)
		if(QDELETED(honked_client) || honked_client == recipient)
			continue
		to_chat(honked_client,
			type = MESSAGE_TYPE_MODCHAT,
			html = "<B><font color='green'>Mentor PM: [key_name_mentor(sender, honked_client, FALSE, FALSE)]-&gt;[key_name_mentor(recipient, honked_client, FALSE, FALSE)]:</B> <font color = #5c00e6> <span class='message linkify'>[message]</span></font>",
			confidential = TRUE)

/datum/world_topic/plx_relayadminsay
	keyword = "PLX_relayadminsay"
	require_comms_key = TRUE

/datum/world_topic/plx_relayadminsay/Run(list/input)
	var/sender = input["sender"]
	var/msg = input["message"]

	if (!sender || !msg)
		return

	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	if(findtext(msg, "@") || findtext(msg, "#"))
		var/list/link_results = check_asay_links(msg)
		if(length(link_results))
			msg = link_results[ASAY_LINK_NEW_MESSAGE_INDEX]
			link_results[ASAY_LINK_NEW_MESSAGE_INDEX] = null
			var/list/pinged_admin_clients = link_results[ASAY_LINK_PINGED_ADMINS_INDEX]
			for(var/iter_ckey in pinged_admin_clients)
				var/client/iter_admin_client = pinged_admin_clients[iter_ckey]
				if(!iter_admin_client?.holder)
					continue
				window_flash(iter_admin_client)
				SEND_SOUND(iter_admin_client.mob, sound('sound/misc/asay_ping.ogg'))

	msg = keywords_lookup(msg)

	// TODO: Load sender's color prefs? idk
	msg = span_adminsay("[span_prefix("ADMIN (DISCORD):")] <EM>[sender]</EM>: <span class='message linkify'>[msg]</span>")

	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINCHAT,
		html = msg,
		confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_say_relay", 1, "Asay external") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/world_topic/plx_relaymentorsay
	keyword = "PLX_relaymentorsay"
	require_comms_key = TRUE

/datum/world_topic/plx_relaymentorsay/Run(list/input)
	var/sender = input["sender"]
	var/msg = input["message"]

	if (!sender || !msg)
		return

	msg = emoji_parse(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	var/list/pinged_mentor_clients = check_mentor_pings(msg)
	if(length(pinged_mentor_clients) && pinged_mentor_clients[ASAY_LINK_PINGED_ADMINS_INDEX])
		msg = pinged_mentor_clients[ASAY_LINK_PINGED_ADMINS_INDEX]
		pinged_mentor_clients -= ASAY_LINK_PINGED_ADMINS_INDEX

	for(var/iter_ckey in pinged_mentor_clients)
		var/client/iter_mentor_client = pinged_mentor_clients[iter_ckey]
		if(!iter_mentor_client?.mentor_datum)
			continue
		window_flash(iter_mentor_client)
		SEND_SOUND(iter_mentor_client.mob, sound('sound/misc/bloop.ogg'))

	log_mentor("MSAY(DISCORD): [sender] : [msg]")
	msg = "<b><font color='#7544F0'><span class='prefix'>DISCORD:</span> <EM>[sender]</EM>: <span class='message linkify'>[msg]</span></font></b>"

	to_chat(GLOB.admins | GLOB.mentors,
		type = MESSAGE_TYPE_MODCHAT,
		html = msg,
		confidential = TRUE)

	SSblackbox.record_feedback("tally", "mentor_say_relay", 1, "Msay external") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#undef TOPIC_EMITTER

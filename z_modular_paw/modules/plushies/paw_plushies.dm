/obj/item/toy/plush/paw
	icon = 'z_modular_paw/modules/plushies/plushies.dmi'

/obj/item/toy/plush/paw/admin/spence
	name = "Dr Spencie Plushie"
	desc = "A plushie depicting a marketable doctor. The tag reads: \"my tamagotchi suit sensor dangles from my wallet chain, it jingles when i skank.\""
	icon_state = "fumo"
	gender = NEUTER
	pet_message = "Spencie grumbles \"something something suit sensors...\""
	squeak_override = list('sound/surgery/scalpel2.ogg' = 1)

/obj/item/toy/plush/paw/admin/spence/click_alt(mob/living/user)
	switch(icon_state)
		if("fumo")
			icon_state = "doll"
			return
		if("doll")
			icon_state = "fumo"
			return
	update_appearance()

/datum/loadout_item/plushies/spence
	name = "spence Plushie"
	item_path = /obj/item/toy/plush/paw/admin/spence

/datum/store_item/plushies/spence
	name = "spence Plushie"
	item_path = /obj/item/toy/plush/paw/admin/spence
	item_cost = 50000

/obj/item/toy/plush/paw/plushiematter
	name = "Plushiematter Crystal"
	desc = "A plushie depicting a surprisingly huggable crystal. Consumer's note: failure to comply with safety regulations may still result in dusting."
	icon_state = "sm"
	gender = FEMALE
	pet_message = "The plushiematter warbles gently at you. I think it likes you."
	squeak_override = list(
		'sound/machines/sm/accent/delam/3.ogg' = 1,
		'sound/machines/sm/accent/delam/24.ogg' = 1,
		'sound/machines/sm/accent/delam/11.ogg' = 1,
		'sound/machines/sm/accent/normal/3.ogg' = 1,
		'sound/machines/sm/accent/normal/8.ogg' = 1,
		'sound/machines/sm/accent/normal/13.ogg' = 1,
		)

/datum/loadout_item/plushies/plushiematter
	name = "plushiematter Plushie"
	item_path = /obj/item/toy/plush/paw/plushiematter

/datum/store_item/plushies/plushiematter
	name = "plushiematter Plushie"
	item_path = /obj/item/toy/plush/paw/plushiematter
	item_cost = 50000

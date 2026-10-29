// SLIME_RANCHER - penned monkeys have become jaded to getting glomped, and thus are less likely to lose their mcfucking marbles
/datum/ai_controller/monkey/on_attacked(datum/source, mob/attacker)
	var/mob/living/basic/slime/slime = astype(attacker)
	if(!slime?.is_ranched())
		return ..()
	if(prob(PENNED_MONKEY_RETALIATE_PROB))
		retaliate(attacker)

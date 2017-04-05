// Includes dance machine, because apparently thats the wish of all players

/obj/machinery/wish_granter
	name = "wish granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	use_power = 0
	anchored = 1
	density = 1

	var/charges = 1
	var/insisting = 0

/obj/machinery/wish_granter/attack_hand(mob/living/carbon/user)
	if(charges <= 0)
		to_chat(user, "The Wish Granter lies silent.")
		return

	else if(!ishuman(user))
		to_chat(user, "You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's.")
		return

	else if(is_special_character(user))
		to_chat(user, "Even to a heart as dark as yours, you know nothing good will come of this.  Something instinctual makes you pull away.")

	else if (!insisting)
		to_chat(user, "Your first touch makes the Wish Granter stir, listening to you.  Are you really sure you want to do this?")
		insisting++

	else
		to_chat(user, "You speak.  [pick("I want the station to disappear","Humanity is corrupt, mankind must be destroyed","I want to be rich", "I want to rule the world","I want immortality.")].  The Wish Granter answers.")
		to_chat(user, "Your head pounds for a moment, before your vision clears.  You are the avatar of the Wish Granter, and your power is LIMITLESS!  And it's all yours.  You need to make sure no one can take it from you.  No one can know, first.")

		charges--
		insisting = 0

		user.dna.add_mutation(HULK)
		user.dna.add_mutation(XRAY)
		user.dna.add_mutation(COLDRES)
		user.dna.add_mutation(TK)

		ticker.mode.traitors += user.mind
		user.mind.special_role = "Avatar of the Wish Granter"

		var/datum/objective/hijack/hijack = new
		hijack.owner = user.mind
		user.mind.objectives += hijack

		user.mind.announce_objectives()

		to_chat(user, "You have a very bad feeling about this.")

	return
	

// DISCO BALL



/obj/machinery/disco
	name = "Radiant Dance Machine Mark IV"
	desc = "The first three prototypes were discontinued after mass casualty incidents."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "disco0"
	anchored = FALSE
	verb_say = "states"
	density = TRUE
	req_access = list(access_engine)
	var/active = FALSE
	var/list/rangers = list()
	var/list/listeners = list()
	var/charge = 35
	var/stop = 0
	var/list/available = list()
	var/list/select_name = list()
	var/list/spotlights = list()
	var/list/sparkles = list()
	var/static/list/songs = list(
		new /datum/track("Engineering's Basic Beat", 					'sound/misc/disco.ogg', 	600, 	5),
		new /datum/track("Engineering's Domination Dance", 				'sound/misc/e1m1.ogg', 		950, 	6),
		new /datum/track("Engineering's Superiority Shimmy", 			'sound/misc/Paradox.ogg', 	2400, 	4),
		new /datum/track("Engineering's Ultimate High-Energy Hustle",	'sound/misc/boogie2.ogg',	1770, 	5),
		)
	var/datum/track/selection = null

/datum/track
	var/song_name = "generic"
	var/song_path = null
	var/song_length = 0
	var/song_beat = 0

/datum/track/New(name, path, length, beat)
	song_name = name
	song_path = path
	song_length = length
	song_beat = beat

/obj/machinery/disco/Initialize()
	..()
	selection = songs[1]


/obj/machinery/disco/Destroy()
	dance_over()
	return ..()

/obj/machinery/disco/attackby(obj/item/O, mob/user, params)
	if(!active)
		if(istype(O, /obj/item/weapon/wrench))
			if(!anchored && !isinspace())
				to_chat(user,"<span class='notice'>You secure the [src] to the floor.</span>")
				anchored = TRUE
			else if(anchored)
				to_chat(user,"<span class='notice'>You unsecure and disconnect the [src].</span>")
				anchored = FALSE
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			return
	return ..()


/obj/machinery/disco/interact(mob/user)
	if (!anchored)
		to_chat(user,"<span class='warning'>This device must be anchored by a wrench!</span>")
		return
	if(!allowed(user))
		to_chat(user,"<span class='warning'>Error: Access Denied - Message: Only the engineering department can be trusted with this kind of power.</span>")
		playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
		return
	if(!Adjacent(user) && !isAI(user))
		return
	user.set_machine(src)
	var/list/dat = list()
	dat +="<div class='statusDisplay' style='text-align:center'>"
	dat += "<b><A href='?src=\ref[src];action=toggle'>[!active ? "BREAK IT DOWN" : "SHUT IT DOWN"]<b></A><br>"
	dat += "</div><br>"
	dat += "<A href='?src=\ref[src];action=select'> Select Track</A><br>"
	dat += "Track Selected: [selection.song_name]<br>"
	dat += "Track Length: [selection.song_length/10] seconds<br><br>"
	dat += "<i>More songs can be unlocked by earning more IEV points</i><br>"
	dat += "<br>DJ's Soundboard:<b><br>"
	dat +="<div class='statusDisplay'><div style='text-align:center'>"
	dat += "<A href='?src=\ref[src];action=horn'>Air Horn</A>  "
	dat += "<A href='?src=\ref[src];action=alert'>Station Alert</A>  "
	dat += "<A href='?src=\ref[src];action=siren'>Warning Siren</A>  "
	dat += "<A href='?src=\ref[src];action=honk'>Honk</A><br>"
	dat += "<A href='?src=\ref[src];action=pump'>Shotgun Pump</A>"
	dat += "<A href='?src=\ref[src];action=pop'>Gunshot</A>"
	dat += "<A href='?src=\ref[src];action=saber'>Esword</A>"
	dat += "<A href='?src=\ref[src];action=harm'>Harm Alarm</A>"
	var/datum/browser/popup = new(user, "vending", "Radiance Dance Machine - Mark IV", 400, 350)
	popup.set_content(dat.Join())
	popup.open()


/obj/machinery/disco/Topic(href, href_list)
	if(..())
		return
	add_fingerprint(usr)
	switch(href_list["action"])
		if("toggle")
			if (QDELETED(src))
				return
			if(!active)
				if(stop > world.time)
					to_chat(usr, "<span class='warning'>Error: The device is still resetting from the last activation, it will be ready again in [round((stop-world.time)/10)] seconds.</span>")
					playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
					return
				active = TRUE
				icon_state = "disco1"
				dance_setup()
				START_PROCESSING(SSobj, src)
				lights_spin()
				updateUsrDialog()
			else if(active)
				active = FALSE
				STOP_PROCESSING(SSobj, src)
				icon_state = "disco0"
				dance_over()
				stop = world.time + 300
				updateUsrDialog()
		if("select")
			if(active)
				to_chat(usr, "<span class='warning'>Error: You cannot change the song until the current one is over.</span>")
				return
			check_GBP()
			select_name = input(usr, "Choose your song", "Track:") as null|anything in available
			if (QDELETED(src))
				return
			for(var/datum/track/S in songs)
				if(select_name == S.song_name)
					selection = S
					break
			updateUsrDialog()
		if("horn")
			deejay('sound/items/AirHorn2.ogg')
		if("alert")
			deejay('sound/misc/notice1.ogg')
		if("siren")
			deejay('sound/machines/engine_alert1.ogg')
		if("honk")
			deejay('sound/items/bikehorn.ogg')
		if("pump")
			deejay('sound/weapons/shotgunpump.ogg')
		if("pop")
			deejay('sound/weapons/Gunshot3.ogg')
		if("saber")
			deejay('sound/weapons/saberon.ogg')
		if("harm")
			deejay('sound/AI/harmalarm.ogg')

/obj/machinery/disco/proc/deejay(var/S)
	if (QDELETED(src) || !active || charge < 5)
		to_chat(usr, "<span class='warning'>The device is not able to play more DJ sounds at this time.</span>")
		return
	charge -= 5
	playsound(src, S,300,1)

/obj/machinery/disco/proc/check_GBP()
	available |= "Engineering's Basic Beat"
	available |= "Engineering's Domination Dance"
	available |= "Engineering's Superiority Shimmy"
	available |= "Engineering's Ultimate High-Energy Hustle"


/obj/machinery/disco/proc/dance_setup()
	stop = world.time + selection.song_length
	var/turf/cen = get_turf(src)
	FOR_DVIEW(var/turf/t, 3, get_turf(src),INVISIBILITY_LIGHTING)
		if(t.x == cen.x && t.y > cen.y)
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "red"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x == cen.x && t.y < cen.y)
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "purple"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x > cen.x && t.y == cen.y)
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "#ffff00"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x < cen.x && t.y == cen.y)
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "green"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x+1 == cen.x && t.y+1 == cen.y) || (t.x+2==cen.x && t.y+2 == cen.y))
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "sw"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x-1 == cen.x && t.y-1 == cen.y) || (t.x-2==cen.x && t.y-2 == cen.y))
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "ne"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x-1 == cen.x && t.y+1 == cen.y) || (t.x-2==cen.x && t.y+2 == cen.y))
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "se"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x+1 == cen.x && t.y-1 == cen.y) || (t.x+2==cen.x && t.y-2 == cen.y))
			var/obj/item/device/flashlight/spotlight/L = new /obj/item/device/flashlight/spotlight(t)
			L.light_color = "nw"
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		continue

/obj/machinery/disco/proc/hierofunk()
	for(var/i in 1 to 10)
		spawn_atom_to_turf(/obj/effect/overlay/temp/hierophant/telegraph/edge, src, 1, FALSE)
		sleep(5)

/obj/machinery/disco/proc/lights_spin()
	for(var/i in 1 to 25)
		if(QDELETED(src) || !active)
			return
		var/obj/effect/overlay/sparkles/S = new /obj/effect/overlay/sparkles(src)
		S.alpha = 0
		sparkles += S
		switch(i)
			if(1 to 8)
				S.orbit(src, 30, TRUE, 60, 36, TRUE, FALSE)
			if(9 to 16)
				S.orbit(src, 62, TRUE, 60, 36, TRUE, FALSE)
			if(17 to 24)
				S.orbit(src, 95, TRUE, 60, 36, TRUE, FALSE)
			if(25)
				S.pixel_y = 7
				S.forceMove(get_turf(src))
		sleep(7)
	if(selection.song_name == "Engineering's Ultimate High-Energy Hustle")
		sleep(280)
	for(var/obj/reveal in sparkles)
		reveal.alpha = 255
	while(active)
		for(var/obj/item/device/flashlight/spotlight/glow in spotlights) // The multiples reflects custom adjustments to each colors after dozens of tests
			if(QDELETED(src) || !active || QDELETED(glow))
				return
			if(glow.light_color == "red")
				glow.light_color = "nw"
				glow.light_power = glow.light_power * 1.48
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "nw")
				glow.light_color = "green"
				glow.light_range = glow.range * 1.1
				glow.light_power = glow.light_power * 2 // Any changes to power must come in pairs to neutralize it for other colors
				glow.update_light()
				continue
			if(glow.light_color == "green")
				glow.light_color = "sw"
				glow.light_power = glow.light_power * 0.5
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "sw")
				glow.light_color = "purple"
				glow.light_power = glow.light_power * 2.27
				glow.light_range = glow.range * 1.15
				glow.update_light()
				continue
			if(glow.light_color == "purple")
				glow.light_color = "se"
				glow.light_power = glow.light_power * 0.44
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "se")
				glow.light_color = "#ffff00"
				glow.light_range = glow.range * 0.9
				glow.update_light()
				continue
			if(glow.light_color == "#ffff00")
				glow.light_color = "ne"
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "ne")
				glow.light_color = "red"
				glow.light_power = glow.light_power * 0.68
				glow.light_range = glow.range * 0.85
				glow.update_light()
				continue
		if(prob(2))
			INVOKE_ASYNC(src, .proc/hierofunk)
		sleep(selection.song_beat)


/obj/machinery/disco/proc/dance(var/mob/living/carbon/M) //Show your moves
	switch(rand(0,9))
		if(0 to 1)
			dance2(M)
		if(2 to 3)
			dance3(M)
		if(4 to 6)
			dance4(M)
		if(7 to 9)
			dance5(M)
	animate(M, transform = null, time = 1, loop = 0)

/obj/machinery/disco/proc/dance2(var/mob/living/carbon/M)
	set waitfor = 0
	for(var/i = 1, i < 8, i++)
		M.SpinAnimation(7,1)
		M.setDir(pick(cardinal))
		sleep(10)

/obj/machinery/disco/proc/dance3(var/mob/living/carbon/M)
	set waitfor = 0
	for(var/i in 1 to 6)
		if (!M)
			return
		M.SpinAnimation(7,1)
		M.setDir(pick(cardinal))
		for (var/x in 1 to 12)
			sleep(1)
			if (!M)
				return
			if (i<5)
				M.pixel_y += 1
			if (i>4)
				M.pixel_y -= 2
			M.setDir(turn(M.dir, 90))
			switch (M.dir)
				if (NORTH)
					M.pixel_y += 3
				if (SOUTH)
					M.pixel_y -= 3
				if (EAST)
					M.pixel_x -= 3
				if (WEST)
					M.pixel_x += 3
		sleep(12)
	M.pixel_x = 0
	M.pixel_y = 0

/obj/machinery/disco/proc/dance4(var/mob/living/carbon/M)
	var/speed = rand(1,3)
	set waitfor = 0
	var/time = 30
	while(time)
		sleep(speed)
		for(var/i in 1 to speed)
			M.setDir(pick(cardinal))
			M.lay_down(TRUE)
		 time--

/obj/machinery/disco/proc/dance5(var/mob/living/carbon/M)
	M.setDir(get_dir(M, src))
	spawn (0)
		if (M)
			animate(M, transform = matrix(180, MATRIX_ROTATE), time = 1, loop = 0)
		sleep (70)
		if (M)
			animate(M, transform = null, time = 1, loop = 0)
	for (var/i = 0, i < 60, i++)
		if (!M)
			return
		if (i<31)
			M.pixel_y += 1
		if (i>30)
			M.pixel_y -= 1
		M.setDir(turn(M.dir, 90))
		switch (M.dir)
			if (NORTH)
				M.pixel_y += 3
			if (SOUTH)
				M.pixel_y -= 3
			if (EAST)
				M.pixel_x -= 3
			if (WEST)
				M.pixel_x += 3
		sleep (1)
	M.pixel_x = 0
	M.pixel_y = 0

/obj/machinery/disco/proc/dance_over()
	for(var/obj/item/device/flashlight/spotlight/SL in spotlights)
		qdel(SL)
	spotlights.Cut()
	for(var/obj/effect/overlay/sparkles/SP in sparkles)
		qdel(SP)
	sparkles.Cut()
	rangers.Cut()
	for(var/mob/living/L in listeners)
		if(!L || !L.client)
			continue
		L.client.stop_client_sounds()
	listeners.Cut()


/obj/machinery/disco/process()
	if(charge<35)
		charge += 1
	if(world.time < stop && active)
		rangers = list()
		for(var/mob/living/M in range(9,src))
			rangers += M
			if(!(M in listeners))
				M.playsound_local(get_turf(M), selection.song_path, 100, channel = CHANNEL_JUKEBOX)
				listeners += M
			if(prob(5+(allowed(M)*3)))
				dance(M)
		for(var/mob/living/L in listeners)
			if(!(L in rangers))
				listeners -= L
				if(!L || !L.client)
					continue
				L.stop_sound_channel(CHANNEL_JUKEBOX)
	else if(active)
		STOP_PROCESSING(SSobj, src)
		dance_over()
		playsound(src,'sound/machines/terminal_off.ogg',50,1)
		active = FALSE
		icon_state = "disco0"

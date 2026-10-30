#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	level.q3Visuals = [];
	level.q3Weapons = [];
	level.q3Models = [];
	level.q3StartWeapons = [];
	level.q3DoorPoll = 0.05;

	addWeapon("gauntlet", undefined, "q3_gauntlet");
	addWeapon("mg", undefined, "q3_mg");
	addWeapon("sg", undefined, "q3_sg");
	addWeapon("gl", undefined, "q3_gl");
	addWeapon("rl", "gl_ak47_mp", "q3_rl");
	addWeapon("lg", undefined, "q3_lg");
	addWeapon("rg", undefined, "q3_rg");
	addWeapon("pg", "gl_g3_mp", "q3_pg");
	addWeapon("bfg", undefined, "q3_bfg");
	addWeapon("grapple", undefined, "q3_grapple");

	precacheItems();
	precacheMissiles();
	thread visuals();

	event("map", ::triggers);
	event("spawn", ::onSpawn);
}

triggers()
{
	addQuakePerk("quad", "Quad Damage", ::quad);
	addQuakePerk("haste", "Haste", ::haste);
	addQuakePerk("invis", "Invisibility", ::none);
	addQuakePerk("regen", "Regeneration", ::none);
	addQuakePerk("flight", "Flight", ::none);
	addQuakePerk("enviro", "Battle Suit", ::none);
	addQuakePerk("medkit", "Medkit", ::none);
	addQuakePerk("teleporter", "Personal Teleporter", ::none);

	sections = getEntArray("q3_section", "targetname");
	for (i = 0; i < sections.size; i++)
		sections[i] thread triggerSection();

	weapons = getEntArray("q3_weapon", "targetname");
	for (i = 0; i < weapons.size; i++)
		weapons[i] thread triggerWeapon();

	perks = getEntArray("q3_perk", "targetname");
	for (i = 0; i < perks.size; i++)
		perks[i] thread triggerPerk();

	ammo = getEntArray("q3_ammo", "targetname");
	for (i = 0; i < ammo.size; i++)
		ammo[i] thread triggerAmmo();

	health = getEntArray("q3_health", "targetname");
	for (i = 0; i < health.size; i++)
		health[i] thread triggerHealth();

	armor = getEntArray("q3_armor", "targetname");
	for (i = 0; i < armor.size; i++)
		armor[i] thread triggerArmor();

	level.q3Shootables = [];
	doors = getEntArray("q3_door", "targetname");
	for (i = 0; i < doors.size; i++)
		doors[i] door(true);
	// getEntArray reads only the engine's own string keys, never script_noteworthy.
	movers = getEntArray("script_brushmodel", "classname");
	for (i = 0; i < movers.size; i++)
	{
		if (isDefined(movers[i].script_noteworthy) && movers[i].script_noteworthy == "func_door")
			movers[i] door(false);
	}

	buttons = getEntArray("q3_button", "targetname");
	for (i = 0; i < buttons.size; i++)
		buttons[i] button();

	uses = getEntArray("q3_use", "targetname");
	for (i = 0; i < uses.size; i++)
		uses[i] thread useLoop();

	teleporters = getEntArray("q3_teleporter", "targetname");
	for (i = 0; i < teleporters.size; i++)
		teleporters[i] thread teleporter();

	pads = getEntArray("q3_push", "targetname");
	for (i = 0; i < pads.size; i++)
		pads[i] thread push(false);

	pads_velocity = getEntArray("q3_push_velocity", "targetname");
	for (i = 0; i < pads_velocity.size; i++)
		pads_velocity[i] thread push(true);
}

// Defrag ships a map in two physics layouts: brushwork, pickups and triggers
// tagged notcpm are gone in CPM, notvq3 in VQ3. Everyone not running CPM gets
// the VQ3 layout, the one with the helping platforms. The server shows each
// player their own brushwork and collides them with it alone (SR-Server's
// Layout); pickups and triggers are gated here.
inLayout(ent)
{
	if (self isQ3CPM())
		return !isDefined(ent.notcpm) || !ent.notcpm;
	return !isDefined(ent.notvq3) || !ent.notvq3;
}

onSpawn()
{
	self thread explosions();

	self.q3Cooldowns = [];
	self.q3Uses = [];
	self.q3Frags = 0;
	self.q3Armor = 0;
	if (self isQ3())
	{
		self unsetPerk("specialty_rof");
		self unsetPerk("specialty_explosivedamage");
	}
	refreshVisuals();
}

precacheItems()
{
	models = [];
	models[models.size] = "q3_health_small";
	models[models.size] = "q3_health";
	models[models.size] = "q3_health_large";
	models[models.size] = "q3_health_mega";
	models[models.size] = "q3_armor_shard";

	for (i = 0; i < models.size; i++)
	{
		precacheModel(models[i]);
		precacheModel(models[i] + "_orb");
	}
	precacheModel("q3_armor_combat");
	precacheModel("q3_armor_body");
}

// What SR-Server draws for the rocket and plasma, which it can only find once the map precached them.
precacheMissiles()
{
	precacheModel("quake_rocket_projectile");
	precacheModel("tag_origin");
	loadFX("q3/rocket_trail");
	loadFX("q3/plasma_fire");
	loadFX("explosions/grenadeExp_default");
	loadFX("q3/plasma_explode");
}

// SR-Server runs the rocket and plasma and pushes everyone itself; a blast here only presses shootable buttons
// and deals damage by the mod's rules.
explosions()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	while (true)
	{
		self waittill("q3_explode", origin, item, hit);

		range = 20;
		damage = 15;
		if (item == level.q3Weapons["rl"])
		{
			range = 120;
			damage = 100;
		}
		self doRadiusDamage(origin, range, damage, 0);
		self blast(origin, range, hit);
	}
}

addWeapon(name, item, model)
{
	level.q3Weapons[name] = item;
	level.q3Models[name] = model;

	if (isDefined(model))
	{
		precacheModel(model);
		box = "q3_ammo_" + name;
		if (name != "gauntlet" && name != "grapple")
		{
			level.q3Models[box] = box;
			precacheModel(box);
		}
	}
}

visuals()
{
	while (true)
	{
		refreshVisuals();
		wait 1;
	}
}

refreshVisuals()
{
	players = getAllPlayers();

	for (i = 0; i < level.q3Visuals.size; i++)
	{
		visual = level.q3Visuals[i];
		visual hide();

		for (j = 0; j < players.size; j++)
		{
			player = IfUndef(players[j] getSpectatorClient(), players[j]);
			if (player isQ3() && player inLayout(visual.q3Owner) && !player onCooldown(visual.q3Owner))
				visual showToPlayer(players[j]);
		}
	}
}

onCooldown(trigger)
{
	if (!isDefined(trigger) || !isDefined(trigger.id) || !isDefined(self.q3Cooldowns))
		return false;

	return isDefined(self.q3Cooldowns[trigger.id]);
}

visualLoop(model, spin)
{
	rest = self restOrigin();
	self.preview = spawnVisual(model, rest);
	if (isDefined(spin))
		self.spinner = spawnVisual(spin, rest);

	wait 0.05;
	self.preview thread bobLoop();
	if (isDefined(self.spinner))
	{
		self.spinner thread bobLoop();
		self.spinner thread spinLoop(-360, 1);
	}
	self.preview spinLoop(360, 2);
}

restOrigin()
{
	drop = 128;
	trace = bulletTrace(self.origin, self.origin - (0, 0, drop), false, self);
	floor = trace["position"];
	if (self.origin[2] - floor[2] < drop)
		return floor + (0, 0, 15);

	return self.origin;
}

spawnVisual(model, origin)
{
	visual = spawn("script_model", origin);
	if (isDefined(model))
		visual setModel(model);

	visual.q3Owner = self;

	level.q3Visuals[level.q3Visuals.size] = visual;
	return visual;
}

spinLoop(yaw, time)
{
	while (true)
	{
		self rotateYaw(yaw, time);
		wait time;
	}
}

bobLoop()
{
	rest = self.origin;

	while (true)
	{
		self moveTo(rest + (0, 0, 8), 1.6, 0.8, 0.8);
		wait 1.6;
		self moveTo(rest, 1.6, 0.8, 0.8);
		wait 1.6;
	}
}

triggerSection()
{
	if (isDefined(self.weapon))
		self.q3Sound = "q3_pickup_weapon";
	else if (isDefined(self.ammo))
		self.q3Sound = "q3_pickup_ammo";

	self thread triggerSectionLoop();
}

triggerSectionLoop()
{
	while (true)
	{
		self waittill("trigger", player);

		if (!player canTrigger(self))
			continue;

		player thread playerSection(self);
	}
}

playerSection(trigger)
{
	self playerPickupSound(trigger);
	if (isDefined(trigger.callback))
		self thread [[trigger.callback]]();
	else
		self sectionKeys(trigger);
	// Whatever else shares the give's name: the gives themselves are gone.
	useTargets(trigger.target, self);

	self removeCooldown(trigger);
}

sectionKeys(trigger)
{
	if (isDefined(trigger.weapon))
		self playerGiveWeapon(trigger.weapon, trigger.ammo);
	else if (isDefined(trigger.ammo))
		self playerAddAmmo(undefined, trigger.ammo);

	if (isDefined(trigger.perk))
		self thread playerGivePerk(trigger.perk, trigger.time);

	if (isDefined(trigger.health))
		self playerAddHealth(trigger.health);

	if (isDefined(trigger.armor))
		self playerAddArmor(trigger.armor);

	if (isDefined(trigger.checkpoint))
		self notify("q3_checkpoint", trigger);
}

addQuakePerk(id, name, callback)
{
	model = "q3_" + id;
	sr\core\_perks::addPerk(id, name, model, callback);

	ring = model + "_ring";
	if (id == "medkit" || id == "teleporter")
	{
		level.perks[id].sound = "q3_pickup_holdable";
		return;
	}
	// Every powerup makes the same noise: Quake plays the health blip for an
	// IT_POWERUP at pickup and keeps the item's own sound - the announcer
	// voice - for the global announcement, which defrag never makes.
	level.perks[id].spin = ring;
	level.perks[id].sound = "q3_pickup_powerup";
	precacheModel(ring);
}

none(perk)
{
}

playerPickupSound(trigger)
{
	if (isDefined(trigger.q3Sound))
		self playLocalSound(trigger.q3Sound);
}

triggerWeapon()
{
	self.q3Sound = "q3_pickup_weapon";
	self thread visualLoop(level.q3Models[self.weapon]);
	self thread triggerWeaponLoop();
}

triggerWeaponLoop()
{
	while (true)
	{
		self waittill("trigger", player);

		if (!player canTrigger(self))
			continue;

		player thread playerWeapon(self);
	}
}

playerWeapon(trigger)
{
	self playerPickupSound(trigger);
	self playerGiveWeapon(trigger.weapon, trigger.ammo);
	self removeCooldown(trigger);
}

playerGiveWeapon(name, ammo)
{
	if (self isQ3W())
		return;

	weapon = level.q3Weapons[name];
	if (!isDefined(weapon))
		return;

	clip = 0;
	if (self hasWeapon(weapon))
		clip = self getWeaponAmmoClip(weapon);

	self giveWeapon(weapon);
	self setWeaponAmmoStock(weapon, 0);
	self setWeaponAmmoClip(weapon, IfUndef(ammo, clip));
	self switchToWeapon(weapon);
}

triggerAmmo()
{
	self.q3Sound = "q3_pickup_ammo";
	self thread visualLoop(level.q3Models["q3_ammo_" + self.weapon]);
	self thread triggerAmmoLoop();
}

triggerAmmoLoop()
{
	while (true)
	{
		self waittill("trigger", player);

		if (!player canTrigger(self))
			continue;

		player thread playerAmmoPickup(self);
	}
}

playerAmmoPickup(trigger)
{
	self playerPickupSound(trigger);
	self playerAddAmmo(trigger.weapon, trigger.ammo);
	self removeCooldown(trigger);
}

playerAddAmmo(name, ammo)
{
	if (self isQ3W())
		return;

	weapon = self ammoWeapon(name);
	if (!isDefined(weapon))
		return;

	if (!self hasWeapon(weapon))
	{
		self giveWeapon(weapon);
		self setWeaponAmmoStock(weapon, 0);
		self setWeaponAmmoClip(weapon, 0);
	}
	self setWeaponAmmoClip(weapon, self getWeaponAmmoClip(weapon) + IfUndef(ammo, 0));
}

// The weapon an ammo pickup feeds: the one it names, or the Q3 weapon in hand.
ammoWeapon(name)
{
	if (isDefined(name))
		return level.q3Weapons[name];

	current = self getCurrentWeapon();
	names = getArrayKeys(level.q3Weapons);
	for (i = 0; i < names.size; i++)
	{
		if (isDefined(level.q3Weapons[names[i]]) && level.q3Weapons[names[i]] == current)
			return current;
	}
	return undefined;
}

triggerHealth()
{
	model = "q3_health_small";
	if (self.health >= 100)
		model = "q3_health_mega";
	else if (self.health >= 50)
		model = "q3_health_large";
	else if (self.health >= 25)
		model = "q3_health";

	self.q3Sound = "q3_pickup" + getSubStr(model, 2, model.size);
	self thread visualLoop(model, model + "_orb");
	self thread triggerHealthLoop();
}

triggerHealthLoop()
{
	while (true)
	{
		self waittill("trigger", player);

		if (!player canTrigger(self))
			continue;

		player thread playerHealthPickup(self);
	}
}

playerHealthPickup(trigger)
{
	self playerPickupSound(trigger);
	self playerAddHealth(trigger.health);
	self removeCooldown(trigger);
}

playerAddHealth(amount)
{
	cap = self.maxhealth * 2;
	health = self.health + IfUndef(amount, 0);

	self.health = Ternary(health > cap, cap, health);
}

triggerArmor()
{
	// Quake gives the red suit the shard's sound, not the yellow one's.
	self.q3Sound = "q3_pickup_armor_shard";
	if (self.armor >= 100)
		self thread visualLoop("q3_armor_body");
	else if (self.armor >= 50)
	{
		self.q3Sound = "q3_pickup_armor";
		self thread visualLoop("q3_armor_combat");
	}
	else
		self thread visualLoop("q3_armor_shard", "q3_armor_shard_orb");

	self thread triggerArmorLoop();
}

triggerArmorLoop()
{
	while (true)
	{
		self waittill("trigger", player);

		if (!player canTrigger(self))
			continue;

		player thread playerArmorPickup(self);
	}
}

playerArmorPickup(trigger)
{
	self playerPickupSound(trigger);
	self playerAddArmor(trigger.armor);
	self removeCooldown(trigger);
}

playerAddArmor(amount)
{
	self.q3Armor = IfUndef(self.q3Armor, 0) + IfUndef(amount, 0);
	self playerAddHealth(amount);
}

triggerPerk()
{
	perk = level.perks[self.perk];
	if (!isDefined(perk))
		return;

	perk.time = self.time;
	self.q3Sound = perk.sound;
	self thread visualLoop(perk.model, perk.spin);
	self thread triggerPerkLoop();
}

triggerPerkLoop()
{
	while (true)
	{
		self waittill("trigger", player);

		if (!player canTrigger(self))
			continue;

		player thread playerPerk(self);
	}
}

playerGivePerk(perk, time)
{
	self endon("death");
	self endon("disconnect");

	self sr\core\_perks::playerSetPerk(perk);

	// A map meaning "for good" says so with a count past what a wait can hold
	// (0xFFFFFE ms, dfwc2014_4's 9999999).
	if (isDefined(time) && time > 0 && time < 16000)
	{
		wait time;
		self sr\core\_perks::playerRemovePerk(perk);
	}
}

playerPerk(trigger)
{
	self playerPickupSound(trigger);
	self thread playerGivePerk(trigger.perk, trigger.time);
	self removeCooldown(trigger);
}

pushFlag(flags, bit)
{
	return (flags & bit) == bit;
}

push(accelerate)
{
	dest = teleporterDest(self.push);
	if (!isDefined(dest))
		return;

	// Quake aims from the middle of the trigger brush; a brush entity has no
	// origin of its own to speak of, so the converter measures it and sends it.
	from = self.origin;
	if (isDefined(self.pad_origin))
		from = self.pad_origin;

	self.q3Velocity = pushVelocity(from, dest.origin);

	self.q3Flags = 0;
	if (accelerate && isDefined(self.spawnflags))
		self.q3Flags = int(self.spawnflags);
	self.q3Speed = 0;
	if (isDefined(self.speed))
		self.q3Speed = int(self.speed);
	self.q3Count = 0;
	if (isDefined(self.count))
		self.q3Count = int(self.count);
	self.q3Accelerate = accelerate;

	// No arc to take a component from and no player-directional speed to stand
	// in for one leaves nothing for the pad to do.
	if (!isDefined(self.q3Velocity) && !pushFlag(self.q3Flags, 1) && !pushFlag(self.q3Flags, 4))
		return;

	self thread pushLoop();
}

pushVelocity(from, to)
{
	gravity = getDvarInt("g_gravity");
	if (gravity <= 0)
		gravity = 800;

	height = to[2] - from[2];
	if (height <= 0)
		return undefined;

	time = sqrt(height / (0.5 * gravity));
	if (time <= 0)
		return undefined;

	flat = (to[0] - from[0], to[1] - from[1], 0);
	forward = length(flat) / time;
	dir = vectorNormalize(flat);

	return (dir[0] * forward, dir[1] * forward, time * gravity);
}

pushLoop()
{
	while (true)
	{
		self waittill("trigger", player);

		if (!player isQ3() || !player inLayout(self))
			continue;

		player thread playerPush(self);
	}
}

playerPush(pad)
{
	self endon("death");
	self endon("disconnect");

	velocity = self getVelocity();

	// The target's own contribution, where there is an arc to take it from.
	// A target below the pad has no arc - Quake would be taking the root of a
	// negative - and that axis contributes nothing rather than something wrong.
	targetXY = (0, 0, 0);
	targetZ = 0;
	arc = isDefined(pad.q3Velocity);
	if (arc)
	{
		targetXY = (pad.q3Velocity[0], pad.q3Velocity[1], 0);
		targetZ = pad.q3Velocity[2];
	}

	// Horizontal.
	if (pushFlag(pad.q3Flags, 1)) // PLAYERDIR_XY
	{
		// A player standing still has no direction of travel to throw along.
		flat = (velocity[0], velocity[1], 0);
		pushXY = (0, 0, 0);
		if (length(flat) > 0.001)
		{
			travel = vectorNormalize(flat);
			pushXY = (travel[0] * pad.q3Speed, travel[1] * pad.q3Speed, 0);
		}
	}
	else
	{
		pushXY = targetXY;
		if (pushFlag(pad.q3Flags, 16) // BIDIRECTIONAL_XY
			&& velocity[0] * pushXY[0] + velocity[1] * pushXY[1] < 0)
			pushXY = (0 - pushXY[0], 0 - pushXY[1], 0);
	}

	// Vertical.
	if (pushFlag(pad.q3Flags, 4)) // PLAYERDIR_Z
	{
		up = 1;
		if (velocity[2] < 0)
			up = -1;
		pushZ = up * pad.q3Count;
	}
	else
	{
		pushZ = targetZ;
		if (pushFlag(pad.q3Flags, 32) && velocity[2] * pushZ < 0) // BIDIRECTIONAL_Z
			pushZ = 0 - pushZ;
	}

	addXY = pushFlag(pad.q3Flags, 2); // ADD_XY
	addZ = pushFlag(pad.q3Flags, 8);  // ADD_Z

	// An axis told to take the target's component when there is no arc to take
	// it from keeps what the player had. Setting it to nothing would stop them
	// dead on an axis the pad was never asked to touch.
	if (!arc && !pushFlag(pad.q3Flags, 1))
		addXY = true;
	if (!arc && !pushFlag(pad.q3Flags, 4))
		addZ = true;

	if (addXY)
		result = (velocity[0] + pushXY[0], velocity[1] + pushXY[1], 0);
	else
		result = (pushXY[0], pushXY[1], 0);

	if (addZ)
		resultZ = velocity[2] + pushZ;
	else
		resultZ = pushZ;

	// CLAMP_NEGATIVE_ADDS: an add that only ever slows the player may not turn
	// them around, so a reversed axis stops at rest instead.
	if (pushFlag(pad.q3Flags, 64))
	{
		if (addXY && velocity[0] * result[0] + velocity[1] * result[1] < 0)
			result = (0, 0, 0);
		if (addZ && velocity[2] * resultZ < 0)
			resultZ = 0;
	}

	// The vanilla pad throws you whole and announces itself; a velocity pad
	// that only trims what you had is meant to go unheard.
	if (!pad.q3Accelerate)
		self playSound("q3_jumppad");

	self setVelocity((result[0], result[1], resultZ));
	self notify("q3_pushed", pad);
}

teleporter()
{
	self.q3Dest = teleporterDest(self.target);
	if (!isDefined(self.q3Dest))
		return;

	self thread teleporterLoop();
}

teleporterDest(name)
{
	if (!isDefined(name))
		return undefined;

	structs = getEntArray(name, "targetname");
	for (i = 0; i < structs.size; i++)
	{
		if (isDefined(structs[i].origin))
			return structs[i];
	}
	return undefined;
}

teleporterLoop()
{
	while (true)
	{
		self waittill("trigger", player);

		if (!player inLayout(self))
			continue;

		player thread playerTeleport(self.q3Dest);
	}
}

playerTeleport(dest)
{
	self endon("death");
	self endon("disconnect");

	self setOrigin(dest.origin);
	self setPlayerAngles(destAngles(dest));
	self setVelocity((0, 0, 0));

	self notify("q3_teleported", dest);
}

destAngles(dest)
{
	if (isDefined(dest.angles))
		return dest.angles;
	if (isDefined(dest.angle))
		return (0, dest.angle, 0);

	return (0, 0, 0);
}

toVector(text)
{
	if (!isDefined(text))
		return (0, 0, 0);

	parts = strTok(text, " ");
	if (parts.size < 3)
		return (0, 0, 0);

	return (ToFloat(parts[0]), ToFloat(parts[1]), ToFloat(parts[2]));
}

// A Quake door. One the converter left as q3_door opens as a player nears; one
// it marked func_door (named, or shot) waits to be used (doorUse).
door(near)
{
	self.q3Shut = self.origin;
	self.q3Open = self.origin + toVector(self.move);
	// START_OPEN: placed open, it shuts where it would have opened to.
	if (pushFlag(IfUndef(self.spawnflags, 0), 1))
	{
		self.q3Open = self.origin;
		self.q3Shut = self.origin + toVector(self.move);
		self.origin = self.q3Shut;
	}
	// Quake's defaults for 0.
	self.q3Speed = IfUndef(self.speed, 0);
	if (self.q3Speed == 0)
		self.q3Speed = 400;
	self.q3Wait = IfUndef(self.time, 0);
	if (self.q3Wait == 0)
		self.q3Wait = 2;
	self.q3Moving = false;

	if (!near)
	{
		self.q3Door = true;
		self.q3State = "shut";
		if (isDefined(self.health) && self.health > 0)
			level.q3Shootables[level.q3Shootables.size] = self;
		return;
	}

	self.q3Travel = distance(self.q3Shut, self.q3Open) / self.q3Speed;
	if (self.q3Travel <= 0)
		return;

	self.q3Range = 256 + distance(self.q3Shut, self.q3Open);

	self thread doorLoop();
}

doorLoop()
{
	while (true)
	{
		player = self doorWanted();
		while (!isDefined(player))
		{
			wait level.q3DoorPoll;
			player = self doorWanted();
		}

		self.q3Moving = true;
		self moveTo(self.q3Open, self.q3Travel);
		wait self.q3Travel;
		useTargets(self.target, player);

		while (isDefined(self doorWanted()))
			wait level.q3DoorPoll;

		if (self.q3Wait < 0)
			return;

		wait self.q3Wait;

		self moveTo(self.q3Shut, self.q3Travel);
		wait self.q3Travel;
		self.q3Moving = false;
	}
}

doorWanted()
{
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		if (!isAlive(players[i]) || !players[i] inLayout(self))
			continue;

		lead = length(players[i] getVelocity()) * (level.q3DoorPoll + self.q3Travel);
		if (distance(players[i].origin, self.q3Shut) < self.q3Range + lead)
			return players[i];
	}
	return undefined;
}

// Quake's Use_BinaryMover on a door: shut, it opens; open, it waits its wait
// again; closing, it opens again. Opening, it carries on rather than turning
// back as Quake's does, so one player cannot shut it on another.
doorUse(activator)
{
	if (self.q3State == "opening")
		return;

	self.q3Activator = activator;
	self notify("q3_door_used");
	self thread doorCycle();
}

// Out to open and back. Quake fires a door's targets once it is fully open, and
// sends it back at once for a negative wait.
doorCycle()
{
	self endon("q3_door_used");
	self.q3Moving = true;

	if (self.q3State != "open")
	{
		self.q3State = "opening";
		time = self doorTime(self.q3Open);
		self moveTo(self.q3Open, time);
		wait time;
		self.q3State = "open";
		useTargets(self.target, self.q3Activator);
	}

	if (self.q3Wait > 0)
		wait self.q3Wait;

	self.q3State = "closing";
	time = self doorTime(self.q3Shut);
	self moveTo(self.q3Shut, time);
	wait time;
	self.q3State = "shut";
	self.q3Moving = false;
}

// What is left of the way at the door's speed; a speed Quake cannot travel at
// still takes a frame.
doorTime(to)
{
	if (self.q3Speed <= 0)
		return 0.05;
	return max(distance(self.origin, to) / self.q3Speed, 0.05);
}

// A Quake button. The converter sends its travel (move) and its box
// (trig_min/trig_max); one with health is shot rather than touched.
button()
{
	self.q3Shut = self.origin;
	self.q3Open = self.origin + toVector(self.move);
	self.q3Moving = false;

	// Quake's defaults for 0. A speed it cannot divide by still takes a frame.
	speed = IfUndef(self.speed, 0);
	if (speed == 0)
		speed = 40;
	self.q3Wait = IfUndef(self.time, 0);
	if (self.q3Wait == 0)
		self.q3Wait = 1;
	self.q3Travel = 0.05;
	if (speed > 0)
		self.q3Travel = max(distance(self.q3Shut, self.q3Open) / speed, 0.05);

	if (isDefined(self.health) && self.health > 0)
		level.q3Shootables[level.q3Shootables.size] = self;
	else
		self thread buttonTouchLoop();
}

// Out, fire the targets for whoever pressed it, back after the wait. Quake
// returns at once for a negative wait, which is how a map makes a target that
// can be shot again straight away.
buttonPress(activator)
{
	self.q3Moving = true;

	self moveTo(self.q3Open, self.q3Travel);
	wait self.q3Travel;
	useTargets(self.target, activator);

	if (self.q3Wait > 0)
		wait self.q3Wait;
	self moveTo(self.q3Shut, self.q3Travel);
	wait self.q3Travel;

	self.q3Moving = false;
}

buttonTouchLoop()
{
	if (!isDefined(self.trig_min) || !isDefined(self.trig_max))
		return;

	while (true)
	{
		player = self buttonToucher();
		if (isDefined(player))
			self buttonPress(player);
		else
			wait 0.05;
	}
}

// Quake presses a button when a player runs into it: the player's box within a
// unit of the button's.
buttonToucher()
{
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		player = players[i];
		if (!isAlive(player) || !player isQ3() || !player inLayout(self))
			continue;

		low = self.trig_min - (16, 16, 71);
		high = self.trig_max + (16, 16, 1);
		if (player.origin[0] >= low[0] && player.origin[0] <= high[0]
			&& player.origin[1] >= low[1] && player.origin[1] <= high[1]
			&& player.origin[2] >= low[2] && player.origin[2] <= high[2])
			return player;
	}
	return undefined;
}

// A rocket or plasma blast presses a shootable button by a direct hit, or by a
// radius reaching its box with a clear line to it (G_RadiusDamage, CanDamage).
// The shooter is who its targets act on. Called rather than notified: a woken
// waittill misses a second blast landing in the same frame.
blast(position, range, hit)
{
	if (!isDefined(level.q3Shootables) || !isPlayer(self) || !self isQ3())
		return;

	for (i = 0; i < level.q3Shootables.size; i++)
	{
		mover = level.q3Shootables[i];
		if (mover.q3Moving || !self inLayout(mover))
			continue;
		if (!(isDefined(hit) && hit == mover) && !mover blastReaches(position, range))
			continue;
		if (isDefined(mover.q3Door))
			mover doorUse(self);
		else
			mover thread buttonPress(self);
	}
}

blastReaches(position, range)
{
	if (!isDefined(self.trig_min) || !isDefined(self.trig_max))
		return false;

	dx = axisDistance(position[0], self.trig_min[0], self.trig_max[0]);
	dy = axisDistance(position[1], self.trig_min[1], self.trig_max[1]);
	dz = axisDistance(position[2], self.trig_min[2], self.trig_max[2]);
	if (length((dx, dy, dz)) >= range)
		return false;

	center = (self.trig_min + self.trig_max) * 0.5;
	return self blastSees(position, center)
		|| self blastSees(position, center + (15, 15, 0))
		|| self blastSees(position, center + (15, -15, 0))
		|| self blastSees(position, center + (-15, 15, 0))
		|| self blastSees(position, center + (-15, -15, 0));
}

blastSees(from, to)
{
	trace = bulletTrace(from, to, false, undefined);
	return trace["fraction"] == 1 || (isDefined(trace["entity"]) && trace["entity"] == self);
}

// A trigger whose targets act on the player who touched it.
useLoop()
{
	while (true)
	{
		self waittill("trigger", player);

		if (!player isQ3() || !player inLayout(self) || !player useReady(self))
			continue;

		useTargets(self.target, player);
	}
}

// Quake's trigger_multiple fires again after its wait, half a second unless
// stated, and never again for a wait of zero or less. Per player here, and
// each life starts over.
useReady(trigger)
{
	id = trigger getEntityNumber();
	if (isDefined(self.q3Uses[id]) && getTime() < self.q3Uses[id])
		return false;

	delay = IfUndef(trigger.time, 0.5);
	if (delay > 0)
		self.q3Uses[id] = getTime() + int(delay * 1000);
	else
		self.q3Uses[id] = 2147483647;
	return true;
}

// Quake's G_UseTargets: what a button or trigger names acts on the player who
// set it off, in that player's own layout. The converter keeps each target's
// Quake classname in script_noteworthy.
useTargets(name, activator)
{
	if (!isDefined(name))
		return;

	targets = getEntArray(name, "targetname");
	for (i = 0; i < targets.size; i++)
		targets[i] useTarget(activator);
}

useTarget(activator)
{
	if (!isDefined(activator) || !isAlive(activator) || !activator inLayout(self) || !isDefined(self.script_noteworthy))
		return;

	switch (self.script_noteworthy)
	{
		case "target_speed":
			activator playerSpeed(self);
			break;
		case "target_push":
			activator playerTargetPush(self);
			break;
		case "target_teleporter":
			dest = teleporterDest(self.target);
			if (isDefined(dest))
				activator thread playerTeleport(dest);
			break;
		case "target_delay":
			self thread delayTargets(activator);
			break;
		case "target_kill":
			activator suicide();
			break;
		case "target_init":
			activator playerInit(self);
			useTargets(self.target, activator);
			break;
		case "target_print":
		case "target_smallprint":
			// Defrag shows it to whoever set it off, or to everyone for BROADCAST.
			if (!isDefined(self.script_hint))
				break;
			if (pushFlag(IfUndef(self.spawnflags, 0), 8))
				iPrintLnBold(self.script_hint);
			else
				activator iPrintLnBold(self.script_hint);
			break;
		case "target_score":
			activator.q3Frags = IfUndef(activator.q3Frags, 0) + Ternary(self.count != 0, self.count, 1);
			break;
		case "target_fragsFilter":
			activator playerFragsFilter(self);
			break;
		case "func_door":
			if (isDefined(self.q3Door))
				self doorUse(activator);
			break;
	}
}

// Defrag's target_init takes back what its flags do not keep: 1 armour,
// 2 health, 4 weapons, 8 powerups, 16 holdables.
playerInit(target)
{
	flags = IfUndef(target.spawnflags, 0);
	if (!pushFlag(flags, 1))
		self.q3Armor = 0;
	if (!pushFlag(flags, 2))
		self.health = self.maxhealth;
	if (!pushFlag(flags, 4) && !self isQ3W())
	{
		names = getArrayKeys(level.q3Weapons);
		for (i = 0; i < names.size; i++)
		{
			if (self hasWeapon(level.q3Weapons[names[i]]))
				self takeWeapon(level.q3Weapons[names[i]]);
		}
	}

	perks = [];
	if (!pushFlag(flags, 8))
	{
		perks[perks.size] = "quad";
		perks[perks.size] = "haste";
		perks[perks.size] = "invis";
		perks[perks.size] = "regen";
		perks[perks.size] = "flight";
		perks[perks.size] = "enviro";
	}
	if (!pushFlag(flags, 16))
	{
		perks[perks.size] = "medkit";
		perks[perks.size] = "teleporter";
	}
	for (i = 0; i < perks.size; i++)
	{
		if (!self sr\core\_perks::playerHasPerk(perks[i]))
			continue;
		self sr\core\_perks::playerRemovePerk(perks[i]);
		if (perks[i] == "haste")
			self setMoveSpeed(320);
	}
}

// Defrag's target_fragsFilter: fires its targets once the player holds the
// frags it asks (count), exactly that many for MATCH (16). REMOVER (1) spends
// them, RESET (8) zeroes the score after, SILENT (4) keeps the shortfall quiet.
playerFragsFilter(filter)
{
	flags = IfUndef(filter.spawnflags, 0);
	need = Ternary(filter.count != 0, filter.count, 1);
	have = IfUndef(self.q3Frags, 0);
	if (have < need || (pushFlag(flags, 16) && have != need))
	{
		if (have < need && !pushFlag(flags, 4))
			self iPrintLnBold((need - have) + " more frags needed");
		return;
	}

	if (pushFlag(flags, 1))
		self.q3Frags = have - need;
	useTargets(filter.target, self);
	if (pushFlag(flags, 8))
		self.q3Frags = 0;
}

delayTargets(activator)
{
	activator endon("disconnect");
	activator endon("death");

	delay = IfUndef(self.time, 0);
	if (delay == 0)
		delay = 1;
	wait max(delay, 0.05);
	useTargets(self.target, activator);
}

// Defrag's target_speed. Spawnflags: 1 PERCENTAGE, 2 ADD, 4/8 +X/-X, 16/32
// +Y/-Y, 64/128 +Z/-Z, 256 LAUNCHER. Defrag's code is closed; this follows
// Xonotic's port of it for Quake maps (target/speed.qc, Q3COMPAT).
playerSpeed(target)
{
	flags = IfUndef(target.spawnflags, 0);
	speed = IfUndef(target.speed, 100);
	add = pushFlag(flags, 2);
	launcher = pushFlag(flags, 256);
	if (!add && speed < 0)
		speed = 0;

	positive = [];
	negative = [];
	positive[0] = pushFlag(flags, 4);
	negative[0] = pushFlag(flags, 8);
	positive[1] = pushFlag(flags, 16);
	negative[1] = pushFlag(flags, 32);
	positive[2] = pushFlag(flags, 64);
	negative[2] = pushFlag(flags, 128);

	// Only the axes the flags name take part; a launcher named both ways on
	// one axis leaves it out.
	velocity = self getVelocity();
	axis = [];
	for (i = 0; i < 3; i++)
	{
		if (launcher && positive[i] && negative[i])
		{
			positive[i] = false;
			negative[i] = false;
		}
		axis[i] = 0;
		if (positive[i] || negative[i])
			axis[i] = velocity[i];
	}

	old = length((axis[0], axis[1], axis[2]));
	if (pushFlag(flags, 1))
		speed = old * speed / 100;

	// A launcher throws along its axes from rest, adding its speed once per
	// axis; otherwise the player's own motion on each axis is the direction,
	// turned the way the flag says.
	launch = 0;
	for (i = 0; i < 3; i++)
	{
		if (positive[i] == negative[i] || (axis[i] == 0 && !launcher))
			continue;
		if (launcher)
		{
			axis[i] = 1;
			launch += speed;
			if (add)
				launch += old;
		}
		axis[i] = abs(axis[i]);
		if (negative[i])
			axis[i] = 0 - axis[i];
	}

	direction = vectorNormalize((axis[0], axis[1], axis[2]));
	if (launcher)
		result = direction * abs(launch);
	else if (add)
		result = direction * speed + velocity;
	else
		result = direction * speed;

	for (i = 0; i < 3; i++)
		axis[i] = Ternary(positive[i] || negative[i], result[i], velocity[i]);

	self setVelocity((axis[0], axis[1], axis[2]));
}

// Quake's target_push sets the velocity outright: toward its target on a pad's
// arc, or along its angles at its speed (1000 unless stated).
playerTargetPush(target)
{
	if (isDefined(target.target))
	{
		dest = teleporterDest(target.target);
		if (!isDefined(dest))
			return;
		velocity = pushVelocity(target.origin, dest.origin);
	}
	else
	{
		speed = IfUndef(target.speed, 0);
		if (speed == 0)
			speed = 1000;
		velocity = moveDir(target.angles) * speed;
	}
	if (!isDefined(velocity))
		return;

	if (pushFlag(IfUndef(target.spawnflags, 0), 1)) // BOUNCEPAD
		self playSound("q3_jumppad");
	self setVelocity(velocity);
	self notify("q3_pushed", target);
}

// G_SetMovedir: a yaw of -1 is straight up and -2 straight down.
moveDir(angles)
{
	if (!isDefined(angles))
		return (1, 0, 0);
	if (angles == (0, -1, 0))
		return (0, 0, 1);
	if (angles == (0, -2, 0))
		return (0, 0, -1);
	return anglesToForward(angles);
}

canTrigger(trigger)
{
	if (!self isQ3() || !self inLayout(trigger) || isDefined(self.q3Cooldowns[trigger.id]))
		return false;

	self.q3Cooldowns[trigger.id] = true;
	refreshVisuals();
	return true;
}

removeCooldown(trigger)
{
	self endon("death");
	self endon("disconnect");

	wait 3;

	self.q3Cooldowns[trigger.id] = undefined;
	refreshVisuals();
}

// Sonic Boom is how pmove sees quad: SR-Server and IW3SR triple the Q3 weapons splash under it.
quad(perk)
{
	self endon("death");
	self endon("disconnect");

	self setPerk("specialty_explosivedamage");

	if (!isDefined(perk.time) || perk.time <= 0)
		return;

	wait perk.time;
	self unsetPerk("specialty_explosivedamage");
}

// Rapid Fire is how pmove sees haste: SR-Server and IW3SR fire the Q3 weapons 1.3x faster under it.
haste(perk)
{
	self endon("death");
	self endon("disconnect");

	self setMoveSpeed(416);
	self setPerk("specialty_rof");

	if (!isDefined(perk.time) || perk.time <= 0)
		return;

	wait perk.time;
	self setMoveSpeed(320);
	self unsetPerk("specialty_rof");
}

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
	defaultWeapons();
	thread visuals();

	event("map", ::triggers);
	event("spawn", ::onSpawn);
}

triggers()
{
	addQuakePerk("quad", "Quad Damage", ::none);
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

	doors = getEntArray("q3_door", "targetname");
	for (i = 0; i < doors.size; i++)
		doors[i] thread door();

	buttons = getEntArray("q3_button", "targetname");
	for (i = 0; i < buttons.size; i++)
		buttons[i] thread button();

	teleporters = getEntArray("q3_teleporter", "targetname");
	for (i = 0; i < teleporters.size; i++)
		teleporters[i] thread teleporter();

	pads = getEntArray("q3_push", "targetname");
	for (i = 0; i < pads.size; i++)
		pads[i] thread push();
}

onSpawn()
{
	self.q3Cooldowns = [];
	self.q3Armor = 0;
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

defaultWeapons()
{
	level.q3StartWeapons[level.q3StartWeapons.size] = "rl";
	level.q3StartWeapons[level.q3StartWeapons.size] = "pg";
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
			if (player isQ3() && !player onCooldown(visual.q3Owner))
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
	weapon = level.q3Weapons[name];
	if (!isDefined(weapon))
		return;

	self giveWeapon(weapon);
	self switchToWeapon(weapon);
	self.scriptedAmmo = IfUndef(ammo, IfUndef(self.scriptedAmmo, 0));
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
	if (isDefined(name))
	{
		weapon = level.q3Weapons[name];
		if (isDefined(weapon) && !self hasWeapon(weapon))
			self giveWeapon(weapon);
	}
	self.scriptedAmmo = IfUndef(self.scriptedAmmo, 0) + IfUndef(ammo, 0);
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

		player playerPerk(self);
	}
}

playerGivePerk(perk, time)
{
	self endon("death");
	self endon("disconnect");

	self sr\core\_perks::playerSetPerk(perk);

	if (isDefined(time) && time > 0)
	{
		wait time;
		self sr\core\_perks::playerRemovePerk(perk);
	}
}

playerPerk(trigger)
{
	self endon("death");
	self endon("disconnect");

	self playerPickupSound(trigger);
	self sr\core\_perks::playerSetPerk(trigger.perk);

	if (trigger.time > 0)
	{
		wait trigger.time;
		self sr\core\_perks::playerRemovePerk(trigger.perk);
	}

	self removeCooldown(trigger);
}

push()
{
	dest = teleporterDest(self.push);
	if (!isDefined(dest))
		return;

	self.q3Velocity = pushVelocity(self.origin, dest.origin);
	if (!isDefined(self.q3Velocity))
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

		if (!player isQ3())
			continue;

		player thread playerPush(self);
	}
}

playerPush(pad)
{
	self endon("death");
	self endon("disconnect");

	self playSound("q3_jumppad");
	self setVelocity(pad.q3Velocity);
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

door()
{
	self.q3Shut = self.origin;
	self.q3Open = self.origin + toVector(self.move);
	self.q3Speed = IfUndef(self.speed, 100);
	self.q3Wait = IfUndef(self.time, 2);
	self.q3Moving = false;

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
		while (!self doorWanted())
			wait level.q3DoorPoll;

		self.q3Moving = true;
		self moveTo(self.q3Open, self.q3Travel);
		wait self.q3Travel;

		while (self doorWanted())
			wait level.q3DoorPoll;
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
		if (!isAlive(players[i]))
			continue;

		lead = length(players[i] getVelocity()) * (level.q3DoorPoll + self.q3Travel);
		if (distance(players[i].origin, self.q3Shut) < self.q3Range + lead)
			return true;
	}
	return false;
}

button()
{
	self.q3Shut = self.origin;
	self.q3Open = self.origin + toVector(self.move);
	self.q3Speed = IfUndef(self.speed, 40);
	self.q3Wait = IfUndef(self.time, 1);

	self.q3Travel = distance(self.q3Shut, self.q3Open) / self.q3Speed;
	self thread buttonLoop();
}

buttonLoop()
{
	while (true)
	{
		while (!self buttonPressed())
			wait 0.1;

		if (self.q3Travel > 0)
		{
			self moveTo(self.q3Open, self.q3Travel);
			wait self.q3Travel;
		}

		self buttonFire();

		wait self.q3Wait;
		if (self.q3Travel > 0)
		{
			self moveTo(self.q3Shut, self.q3Travel);
			wait self.q3Travel;
		}
	}
}

buttonPressed()
{
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		if (!isAlive(players[i]) || !players[i] isQ3())
			continue;
		if (distance(players[i].origin, self.q3Shut) < 128)
			return true;
	}
	return false;
}

buttonFire()
{
	if (!isDefined(self.target))
		return;

	targets = getEntArray(self.target, "targetname");
	for (i = 0; i < targets.size; i++)
		targets[i] notify("q3_button", self);
}

canTrigger(trigger)
{
	if (!self isQ3() || isDefined(self.q3Cooldowns[trigger.id]))
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

haste(perk)
{
	self endon("death");
	self endon("disconnect");

	self setMoveSpeed(416);
	wait perk.time;
	self setMoveSpeed(320);
}

#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
	level.weapons = [];

	event("connect", ::loop);

	addWeapon("player", "RPG", "bt_rpg_mp", 0.51, 1.05, "projectile_rpg7",
		"muzzleflashes/at4_flash", "explosions/grenadeExp_default", "smoke/smoke_geotrail_rpg",
		"weap_rpg_fire_plr", "weap_rpg_loop", "weap_rpg_loop", 500, true, 140);

	addWeapon("player", "FN RPG", "gl_g36c_mp", 0.51, 1.05, "projectile_rpg7",
		"muzzleflashes/at4_flash", "explosions/grenadeExp_default", "smoke/smoke_geotrail_rpg",
		"weap_rpg_fire_plr", "weap_rpg_loop", "weap_rpg_loop", 1000, true, 140);

	addWeapon("player", "Q3 Rocket", "gl_ak47_mp", 0, 0.8, "quake_rocket_projectile",
		"muzzleflashes/m203_flshview", "explosions/grenadeExp_default", "q3/rocket_trail",
		"weap_quake_rocket_shoot", "weap_quake_rocket_loop", "weap_quake_rocket_explode", 500, true, 120);

	addWeapon("owner", "Q3 Plasma", "gl_g3_mp", 0, 0.05, "tag_origin",
		"muzzleflashes/mist_mk2_flashview", undefined, "q3/plasma_fire",
		"weap_quake_plasma_shoot", undefined, "weap_quake_plasma_explode", 30, true, 40);
}

addWeapon(admin, name, item, predelay, delay, model,
	muzzle, impact, trail, sfx_shoot, sfx_trail, sfx_impact, power,
	knockback, knockback_distance)
{
	index = level.weapons.size;

	level.weapons[index] 						= [];
	level.weapons[index]["admin"]				= admin;
	level.weapons[index]["name"]				= name;
	level.weapons[index]["item"]				= item;
	level.weapons[index]["predelay"]			= predelay;
	level.weapons[index]["delay"]				= delay;
	level.weapons[index]["model"]				= model;
	level.weapons[index]["sfx_shoot"]			= sfx_shoot;
	level.weapons[index]["sfx_trail"]			= sfx_trail;
	level.weapons[index]["sfx_impact"]			= sfx_impact;
	level.weapons[index]["power"] 				= power;
	level.weapons[index]["knockback"] 			= knockback;
	level.weapons[index]["knockback_distance"] 	= knockback_distance;

	if (isDefined(muzzle))
		level.weapons[index]["muzzle"]			= loadFx(muzzle);
	if (isDefined(impact))
		level.weapons[index]["impact"]			= loadFx(impact);
	if (isDefined(trail))
		level.weapons[index]["trail"]			= loadFx(trail);
	precacheModel(model);
}

loop()
{
	self endon("disconnect");

	wait 0.05;

	while (true)
	{
		if (!self isReallyAlive() || !self hasWeaponBT())
		{
			wait 0.05;
			continue;
		}
		if (self attackButtonPressed() || self getDemoButtons() & 1)
		{
			weapon = self getWeaponBT();
			if (!isDefined(weapon))
				continue;

			self shoot(weapon);
		}
		wait 0.05;
	}
}

shoot(weapon)
{
	wait weapon["predelay"];

	bullet = spawnStruct();
	bullet.weapon = weapon;
	bullet.player = self;

	eye = self eyepos();
	forward = anglesToForward(self getPlayerAngles()) * 999999;
	bullet.model = spawn("script_model", eye);
	bullet.model setContents(0);
	bullet.model setModel(weapon["model"]);

	if (self.sr_mode == "Defrag")
	{
		bullet.model hide();
		bullet.model showToPlayer(self);
	}

	ignore = [];
	ignore[ignore.size] = self;
	trace = traceArray(eye, eye + forward, false, ignore);

	oldpos = trace["position"];
	pos = oldpos;
	normal = trace["normal"];
	angles = vectortoangles(normal);
	right = anglestoright(angles);
	up = anglestoup(angles);

	trace["position"] = pos;
	trace["fx_position"] = pos + normal * 1;
	trace["start_position"] = eye;
	trace["old_position"] = oldpos;
	trace["angles"] = angles;
	trace["up"] = up;
	bullet.trace = trace;

	oldpos = trace["old_position"];
	fxpos = trace["fx_position"];
	p = trace["start_position"];
	p += vectornormalize(oldpos - p) * 33;
	speed = 1500;
	time = length(fxpos - p) / speed * 1.5;

	// Shoot
	if (isDefined(weapon["sfx_shoot"]))
		self playSoundToPlayer(weapon["sfx_shoot"], self);
	if (isDefined(weapon["sfx_trail"]) && self.sr_mode != "Defrag")
		bullet.model playLoopSound(weapon["sfx_trail"]);
	bullet.model.angles = self getPlayerAngles();
	bullet thread trailFX();

	// Impact
	bullet.model moveTo(trace["position"], time);
	bullet thread impact(time);

	delay = weapon["delay"];
	if (self sr\game\_perks::playerHasPerk("haste"))
		delay /= 1.3;
	if (delay >= 0.05)
		wait delay;
}

impact(time)
{
	self.player endon("disconnect");
	self.player endon("death");
	self thread impactDelete();

	wait time;

	self.model stopLoopSound();
	if (isDefined(self.weapon["sfx_impact"]))
		self.model playSound(self.weapon["sfx_impact"]);

	if (self.weapon["knockback"] &&
		(self.player.sr_mode == "Defrag" || self.player sr\player\modes\_main::isInMode("defrag")))
		self thread knockback();

	self.model.angles = self.trace["angles"];
	if (isDefined(self.weapon["impact"]))
		playFXOnTag(self.weapon["impact"], self.model, "tag_origin");

	wait 0.1;
	if (isDefined(self.model))
		self.model delete();
}

impactDelete()
{
	self.player waittill_any("disconnect", "death");

	if (isDefined(self.model))
		self.model delete();
}

knockback()
{
	n = distance(self.trace["position"], self.player.origin);
	position = self.trace["position"];
	direction = self.player eyePos() - self.trace["position"];

	if (int(n) > self.weapon["knockback_distance"])
		return;

	self.player bounce(position, direction, self.weapon["power"], 2);
}

trailFX()
{
	wait 0.05;

	if (isDefined(self.model))
	{
		if (isDefined(self.weapon["muzzle"]))
			playFXOnTag(self.weapon["muzzle"], self.model, "tag_origin");
		if (isDefined(self.weapon["trail"]))
			playFXOnTag(self.weapon["trail"], self.model, "tag_origin");
	}
}

hasWeaponBT()
{
	self endon("disconnect");

	for (i = 0; i < level.weapons.size; i++)
	{
		if (level.weapons[i]["item"] == self getCurrentWeapon())
			return true;
	}
	return false;
}

getWeaponBT()
{
	self endon("disconnect");

	for (i = 0; i < level.weapons.size; i++)
	{
		if (level.weapons[i]["item"] == self getCurrentWeapon())
			return level.weapons[i];
	}
	return undefined;
}

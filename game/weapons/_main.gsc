#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
	level.weapons = [];

	event("connect", ::loop);

	addWeapon("player", "RPG", "bt_rpg_mp", 0.51, 1.05, "projectile_rpg7",
		"muzzleflashes/at4_flash", "explosions/grenadeExp_concrete_1", "smoke/smoke_geotrail_rpg",
		"weap_rpg_fire_plr", "weap_rpg_loop", "weap_rpg_loop", 500, true, 140);

	addWeapon("player", "FN RPG", "gl_g36c_mp", 0.51, 1.05, "projectile_rpg7",
		"muzzleflashes/at4_flash", "explosions/grenadeExp_concrete_1", "smoke/smoke_geotrail_rpg",
		"weap_rpg_fire_plr", "weap_rpg_loop", "weap_rpg_loop", 1000, true, 140);

	addWeapon("player", "Q3 Rocket", "gl_ak47_mp", 0, 0.6, "quake_rocket_projectile",
		"muzzleflashes/m203_flshview", "explosions/grenadeExp_concrete_1", "q3/rocket_trail",
		"weap_quake_rocket_shoot", "weap_quake_rocket_loop", "weap_quake_rocket_explode", 500, true, 140);

	addWeapon("owner", "Q3 Plasma", "gl_g3_mp", 0, 0.05, "tag_origin",
		"muzzleflashes/mist_mk2_flashview", "q3/plasma_explode", "q3/plasma_fire",
		"weap_quake_plasma_shoot", "", "weap_quake_plasma_explode", 30, true, 60);
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
	level.weapons[index]["muzzle"]				= loadFx(muzzle);
	level.weapons[index]["impact"]				= loadFx(impact);
	level.weapons[index]["trail"]				= loadFx(trail);
	level.weapons[index]["sfx_shoot"]			= sfx_shoot;
	level.weapons[index]["sfx_trail"]			= sfx_trail;
	level.weapons[index]["sfx_impact"]			= sfx_impact;
	level.weapons[index]["power"] 				= power;
	level.weapons[index]["knockback"] 			= knockback;
	level.weapons[index]["knockback_distance"] 	= knockback_distance;

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
			wait 1;
			continue;
		}
		if (self attackButtonPressed())
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
	bullet.model setModel(weapon["model"]);

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
	self playSoundToPlayer(weapon["sfx_shoot"], self);
	bullet.model playLoopSound(weapon["sfx_trail"]);
	bullet.model.angles = self getPlayerAngles();
	bullet thread trailFX();

	// Impact
	bullet.model moveTo(trace["position"], time);
	bullet thread impact(time);

	delay = weapon["delay"];
	if (self sr\game\_perks::playerHasPerk("haste"))
		delay /= 1.5;
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
	self.model playSound(self.weapon["sfx_impact"]);

	if (self.weapon["knockback"] &&
		(self.player.sr_mode == "Defrag" || self.player sr\player\modes\_main::isInMode("defrag")))
		self thread knockback();

	playFX(self.weapon["impact"], self.trace["fx_position"], self.trace["normal"], self.trace["up"]);

	wait 0.05;
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
		playFXOnTag(self.weapon["muzzle"], self.model, "TAG_ORIGIN");
		playFXOnTag(self.weapon["trail"], self.model, "TAG_ORIGIN");
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

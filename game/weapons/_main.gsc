#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
	level.btWeapons = [];

	event("connect", ::loop);

	addWeapon("player", "RPG", "bt_rpg_mp", 0.51, 1.05, "projectile_rpg7",
		"muzzleflashes/at4_flash", "explosions/grenadeExp_concrete_1", "smoke/smoke_geotrail_rpg",
		"weap_rpg_fire_plr", "weap_rpg_loop", "weap_rpg_loop", 500);

	addWeapon("player", "FN RPG", "gl_g36c_mp", 0.51, 1.05, "projectile_rpg7",
		"muzzleflashes/at4_flash", "explosions/grenadeExp_concrete_1", "smoke/smoke_geotrail_rpg",
		"weap_rpg_fire_plr", "weap_rpg_loop", "weap_rpg_loop", 1500);

	addWeapon("player", "Q3 Rocket", "gl_ak47_mp", 0, 0.6, "quake_rocket_projectile",
		"muzzleflashes/m203_flshview", "explosions/grenadeExp_concrete_1", "q3/rocket_trail",
		"weap_quake_rocket_shoot", "weap_quake_rocket_loop", "weap_quake_rocket_explode", 500);

	addWeapon("owner", "Q3 Plasma", "gl_g3_mp", 0, 0.05, "tag_origin",
		"muzzleflashes/mist_mk2_flashview", "q3/plasma_explode", "q3/plasma_fire",
		"weap_quake_plasma_shoot", "", "weap_quake_plasma_explode", 30);
}

addWeapon(admin, name, item, predelay, delay, model,
	muzzle, impact, trail, sfx_shoot, sfx_trail, sfx_impact, power)
{
	index = level.btWeapons.size;

	level.btWeapons[index] = [];
	level.btWeapons[index]["admin"]			= admin;
	level.btWeapons[index]["name"]			= name;
	level.btWeapons[index]["item"]			= item;
	level.btWeapons[index]["predelay"]		= predelay;
	level.btWeapons[index]["delay"]			= delay;
	level.btWeapons[index]["model"]			= model;
	level.btWeapons[index]["muzzle"]		= loadFx(muzzle);
	level.btWeapons[index]["impact"]		= loadFx(impact);
	level.btWeapons[index]["trail"]			= loadFx(trail);
	level.btWeapons[index]["sfx_shoot"]		= sfx_shoot;
	level.btWeapons[index]["sfx_trail"]		= sfx_trail;
	level.btWeapons[index]["sfx_impact"]	= sfx_impact;
	level.btWeapons[index]["power"] 		= power;

	precacheModel(model);
}

loop()
{
	self endon("disconnect");

	while (true)
	{
		if (!self isReallyAlive() || !self isWeaponBT())
		{
			wait 1;
			continue;
		}
		if (self attackButtonPressed())
		{
			weapon = self getWeaponBT();
			if (!isDefined(weapon))
				continue;

			self btShoot(weapon);
		}
		wait 0.05;
	}
}

btShoot(weapon)
{
	wait weapon["predelay"];

	if (!self sr\sys\_admins::isRole(weapon["admin"]))
		return;

	eye = self eyepos();
	forward = anglesToForward(self getPlayerAngles()) * 999999;
	bullet = spawn("script_model", eye);
	bullet setModel(weapon["model"]);

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

	oldpos = trace["old_position"];
	fxpos = trace["fx_position"];
	p = trace["start_position"];
	p += vectornormalize(oldpos - p) * 33;
	speed = 1500;
	time = length(fxpos - p) / speed * 1.5;

	// Shoot
	self playSoundToPlayer(weapon["sfx_shoot"], self);
	bullet playLoopSound(weapon["sfx_trail"]);
	bullet.angles = self getPlayerAngles();
	bullet thread btTrailFX(weapon["trail"], weapon["muzzle"]);

	// Impact
	bullet moveTo(trace["position"], time);
	bullet thread btImpact(self, trace, weapon, time);

	wait weapon["delay"];
}

btImpact(player, trace, weapon, time)
{
	wait time;
	self stopLoopSound();
	self playSound(weapon["sfx_impact"]);

	if (isDefined(player.bt_knockback) && player.bt_knockback)
		self thread btKnockback(player, trace, weapon["power"]);

	playFX(weapon["impact"], trace["fx_position"], trace["normal"], trace["up"]);

	wait 0.05;
	self delete();
}

btKnockback(player, trace, power)
{
	n = distance(trace["position"], player.origin);

	if (int(n) > 80)
		return;

	player bounce(trace["position"], player.origin - trace["position"], power);
}

btTrailFX(trail, muzzle)
{
	wait 0.05;
	playfxontag(muzzle, self, "TAG_ORIGIN");
	playfxontag(trail, self, "TAG_ORIGIN");
}

isWeaponBT()
{
	self endon("disconnect");

	for (i = 0; i < level.btWeapons.size; i++)
	{
		if (level.btWeapons[i]["item"] == self getCurrentWeapon())
			return true;
	}
	return false;
}

getWeaponBT()
{
	self endon("disconnect");

	for (i = 0; i < level.btWeapons.size; i++)
	{
		if (level.btWeapons[i]["item"] == self getCurrentWeapon())
			return level.btWeapons[i];
	}
	return undefined;
}

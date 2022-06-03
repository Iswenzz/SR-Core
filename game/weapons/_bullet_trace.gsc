/*

  _|_|_|            _|      _|      _|                  _|
_|        _|    _|    _|  _|        _|          _|_|    _|  _|_|_|_|
  _|_|    _|    _|      _|          _|        _|    _|  _|      _|
      _|  _|    _|    _|  _|        _|        _|    _|  _|    _|
_|_|_|      _|_|_|  _|      _|      _|_|_|_|    _|_|    _|  _|_|_|_|

Map and GSC Made By SuX Lolz.

Steam: http://steamcommunity.com/profiles/76561198163403316/
Discord: https://discord.gg/76aHfGF
Youtube: https://www.youtube.com/channel/UC1vxOXBzEF7W4g7TRU0C1rw
Paypal: suxlolz@outlook.fr
Email Pro: suxlolz@outlook.fr

*/
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include braxi\_common;

main()
{
	/*

	name 	   = filename
	predelay   = record and check in vegas
	delay	   = record and check in vegas
	model 	   = projectileModel
	muzzle 	   = viewFlashEffect
	impact 	   = projExplosionEffect
	trail 	   = projTrailEffect
	sfx_shoot  = fireSoundPlayer
	sfx_trail  = projectileSound
	sfx_impact = projExplosionSound
	power 	   = knockback multiplier

	*/

	level.bt_weap = [];

	level.bt_weap["name"]       [0] = "bt_rpg_mp";
	level.bt_weap["predelay"]   [0] = 0.51;
	level.bt_weap["delay"]      [0] = 1;
	level.bt_weap["model"]      [0] = "projectile_rpg7";
	level.bt_weap["muzzle"]     [0] = loadFX("muzzleflashes/at4_flash");
	level.bt_weap["impact"]     [0] = loadFX("explosions/grenadeExp_concrete_1");
	level.bt_weap["trail"]      [0] = loadFX("smoke/smoke_geotrail_rpg");
	level.bt_weap["sfx_shoot"]  [0] = "weap_rpg_fire_plr";
	level.bt_weap["sfx_trail"]  [0] = "weap_rpg_loop";
	level.bt_weap["sfx_impact"] [0] = "weap_rpg_loop";
	level.bt_weap["power"]      [0] = 3;

	level.bt_weap["name"]       [1] = "gl_ak47_mp"; // Q3 Rocket
	level.bt_weap["predelay"]   [1] = 0;
	level.bt_weap["delay"]      [1] = 0.8;
	level.bt_weap["model"]      [1] = "quake_rocket_projectile";
	level.bt_weap["muzzle"]     [1] = loadFX("muzzleflashes/m203_flshview");
	level.bt_weap["impact"]     [1] = loadFX("explosions/grenadeExp_concrete_1");
	level.bt_weap["trail"]      [1] = loadFX("q3/rocket_trail");
	level.bt_weap["sfx_shoot"]  [1] = "weap_quake_rocket_shoot";
	level.bt_weap["sfx_trail"]  [1] = "weap_quake_rocket_loop";
	level.bt_weap["sfx_impact"] [1] = "weap_quake_rocket_explode";
	level.bt_weap["power"]      [1] = 3;

	level.bt_weap["name"]       [2] = "gl_g3_mp"; // Q3 Plasma
	level.bt_weap["predelay"]   [2] = 0;
	level.bt_weap["delay"]      [2] = 0.05;
	level.bt_weap["model"]      [2] = "tag_origin";
	level.bt_weap["muzzle"]     [2] = loadFX("muzzleflashes/mist_mk2_flashview");
	level.bt_weap["impact"]     [2] = loadFX("q3/plasma_explode");
	level.bt_weap["trail"]      [2] = loadFX("q3/plasma_fire");
	level.bt_weap["sfx_shoot"]  [2] = "weap_quake_plasma_shoot";
	level.bt_weap["sfx_trail"]  [2] = "";
	level.bt_weap["sfx_impact"] [2] = "weap_quake_plasma_explode";
	level.bt_weap["power"]      [2] = 1.5;

	level.bt_weap["name"]       [3] = "gl_g36c_mp"; // FN RPG
	level.bt_weap["predelay"]   [3] = 0.51;
	level.bt_weap["delay"]      [3] = 1;
	level.bt_weap["model"]      [3] = "projectile_rpg7";
	level.bt_weap["muzzle"]     [3] = loadFX("muzzleflashes/at4_flash");
	level.bt_weap["impact"]     [3] = loadFX("explosions/grenadeExp_concrete_1");
	level.bt_weap["trail"]      [3] = loadFX("smoke/smoke_geotrail_rpg");
	level.bt_weap["sfx_shoot"]  [3] = "weap_rpg_fire_plr";
	level.bt_weap["sfx_trail"]  [3] = "weap_rpg_loop";
	level.bt_weap["sfx_impact"] [3] = "weap_rpg_loop";
	level.bt_weap["power"]      [3] = 3;

	for (i=0;i<level.bt_weap["model"].size;i++)
		precacheModel(level.bt_weap["model"][i]);
}

bt_check()
{
	self notify("bt_weapon_switched");
	wait 0.05;
	self endon("disconnect");
	self endon("bt_weapon_switched");

	while (true) // more opti to check first if they have the weapon and loop every sec, then if they have it 0.05.
	{
		if (self isWeaponBT() != "")
			break;
		wait 1;
	}

	while (true)
	{
		if (!self isReallyAlive() || self isWeaponBT() == "")
		{
			self thread bt_check();
			return;
		}

		if (self attackButtonPressed())
		{
			weapon = self getWeaponBT();

			if (!isStringInt(weapon))
			{
				wait 0.05;
				continue;
			}

			wait level.bt_weap["predelay"][weapon];
			self thread bt_shoot(level.bt_weap["name"][weapon],level.bt_weap["model"][weapon],level.bt_weap["muzzle"][weapon],level.bt_weap["impact"][weapon],level.bt_weap["trail"][weapon],level.bt_weap["sfx_shoot"][weapon],level.bt_weap["sfx_trail"][weapon],level.bt_weap["sfx_impact"][weapon],level.bt_weap["power"][weapon]);
			wait level.bt_weap["delay"][weapon];
		}

		wait 0.05;
	}
}

bt_shoot(name,model,muzzle,impact,trail,sfx_shoot,sfx_trail,sfx_impact,power)
{
	if (name == "plasma_mp" && self.sr_group != "owner")
		return;

	eye = self eyepos();
	forward = anglesToForward(self getPlayerAngles()) * 999999;
	bullet = spawn("script_model", eye);
	bullet setModel(model);
	trace = trace_array(eye, eye + forward, false, self);

	oldpos = trace["position"];
	pos = oldpos;
	normal = trace["normal"];
	angles = vectortoangles(normal);

	on_ground = false;
	on_terrain = false;

	if (on_ground )
		angles = (angles[0], self getPlayerAngles()[1] - 180, 0);

	right = anglestoright(angles);
	up = anglestoup(angles);

	trace["position"] = pos;
	trace["fx_position"] = pos + normal*1;
	trace["start_position"] = eye;
	trace["old_position"] = oldpos;
	trace["angles"] = angles;
	trace["up"] = up;

	oldpos = trace["old_position"];
	fxpos = trace["fx_position"];
	p = trace["start_position"];
	p += vectornormalize(oldpos - p) * 33;
	self.owner = self;
	speed = 1500;
	time = length(fxpos - p) / speed*1.5;

	self playSoundToPlayer(sfx_shoot,self);

	bullet playLoopSound(sfx_trail);
	bullet.angles = self getPlayerAngles();
	bullet thread bt_fx_trail(trail,muzzle);

	bullet moveTo(trace["position"],time);
	wait time;
	bullet stopLoopSound();
	bullet playSound(sfx_impact);

	if (isDefined(self.bt_knockback) && self.bt_knockback)
		bullet thread bt_knockback(self,trace,power);

	playFX(impact, fxpos, trace["normal"], trace["up"]);

	wait 0.05;
	bullet delete();
}

bt_knockback(player,trace,power)
{
	n = Distance2D(trace["position"], player.origin);

	if (int(n) > 50)
		return;

	vec = trace["position"] - player.origin;
	pos = player getVelocity() - vec;

	player setVelocity(pos*power);
}

bt_fx_trail(trail,muzzle)
{
	wait 0.05;
	playfxontag(muzzle, self, "TAG_ORIGIN");
	playfxontag(trail, self, "TAG_ORIGIN");
}

isWeaponBT()
{
	self endon("disconnect");
	self endon("bt_weapon_switched");

	weapon = "";

	for (i=0;i<level.bt_weap["name"].size;i++)
	{
		if (level.bt_weap["name"][i] == self getCurrentWeapon())
		{
			weapon = level.bt_weap["name"][i];
			break;
		}
	}

	return weapon;
}

getWeaponBT()
{
	self endon("disconnect");
	self endon("bt_weapon_switched");

	weapon = "";

	for (i=0;i<level.bt_weap["name"].size;i++)
	{
		if (level.bt_weap["name"][i] == self getCurrentWeapon())
		{
			weapon = i;
			break;
		}
	}

	return weapon;
}

trace_array(start, end, hit_players, ignore_array)
{
	if (!isDefined(hit_players))
		hit_players = false;

	trace = bullettrace(start, end, hit_players, self);

	return trace;
}

eyepos()
{
	return self eye() + self.origin;
}

eye()
{
	switch (self getstance())
	{
		case "crouch":	height = (0,0,40);
		break;
		case "prone":	height = (0,0,11);
		break;
		default:		height = (0,0,60);
	}

	if (!isDefined(self))
		return;

	return height;
}
#include sr\libs\portal\_portal;
#include sr\libs\portal\_general;
#include sr\utils\_math;

trackGrenade(grenade, weaponName, cookTime)
{
	min_length = 50;

	_info["is_c4"] = false;
	_info["radius"] = 5;
	_info["weapon"] = weaponName;

	switch (weaponName)
	{
		case "c4_mp":
			_info["fuse_time"] = 20;
			_info["model"] = "weapon_c4";
			_info["is_c4"] = true;
			_info["radius"] = 10;
			break;

		case "concussion_grenade_mp":
			_info["fuse_time"] = 0.95;
			_info["model"] = "weapon_concussion_grenade";
			break;

		case "flash_grenade_mp":
			_info["fuse_time"] = 1.4;
			_info["model"] = "weapon_m84_flashbang_grenade";
			break;

		case "smoke_grenade_mp":
			_info["fuse_time"] = 1;
			_info["model"] = "projectile_us_smoke_grenade";
			break;

		default:
			_info["fuse_time"] = 4;
			_info["model"] = "projectile_m67fraggrenade";
			break;
	}
	grenade setcontents(0);
	if (weaponName != "frag_grenade_mp")
		cookTime = 0;

	restTime = _info["fuse_time"] - cookTime;
	if (weaponName == "frag_grenade_mp")
		grenade thread grenadeWatchExplosionForTurrets(restTime);
	else if (weaponName == "c4_mp")
		grenade thread c4watchExplosionForTurrets(self);

	if (WeaponName != "c4_mp")
		grenade notify("detonate");

	old_pos = self eyepos();
	vel = anglestoforward(self getplayerangles())*min_length;
	firstloop = true;
	original_grenade = grenade;

	for (i = int(restTime * 20); i > 0 && isDefined(original_grenade) && isDefined(grenade); i--)
	{
		if (level.portals.size >= 2)
		{
			if (firstloop)
				firstloop = false;
			else
				vel = grenade.origin - old_pos - (0, 0, 2);

			for (n = 0; n < level.portals.size; n++)
			{
				if (!level.portals[n].active)
					continue;

				p1 = level.portals[n].trace;
				if (vectordot(vel,p1["normal"]) >= 0 || vectordot(grenade.origin - level.portals[n].trace["position"], p1["normal"]) <= 0)
					continue;

				vec = grenade.origin - p1["position"] - p1["normal"] * _info["radius"];
				x = vectordot(vec, p1["right"]);
				y = vectordot(vec, p1["up"]);
				z = vectordot((vec + vel), p1["normal"]);
				inportal = isInPortal(x, y, -12, -12) && z <= 0;

				if (inportal)
				{
					grenade notify("physics_stop");
					grenade.origin = grenade.origin + vel;
					old_grenade = grenade;

					p2 = level.portals[n].otherportal.trace;
					pos = p2["fx_position"] + x * p2["right"] * -1 + y * p2["up"];
					vel_out = vectordot(vel, p1["right"] * -1) * p2["right"] + vectordot(vel, p1["up"]) * p2["up"] + vectordot(vel, p1["normal"] * -1) * p2["normal"];

					grenade = grenadeSpawn(pos, vel_out, _info["model"], _info["is_c4"]);
					grenade.originalGrenade = original_grenade;

					original_grenade hide();
					original_grenade _linkto(grenade);

					wait 0.05;

					old_grenade notify("delete");
					if (isDefined(old_grenade) && old_grenade != original_grenade)
						old_grenade delete();

					i--;
					break;
				}
			}
		}
		if (grenade != original_grenade && !_info["is_c4"])
			grenade rotateto(original_grenade.angles, 0.05);
		old_pos = grenade.origin;
		wait 0.05;
	}
	grenade notify("remove");
}


grenadeSpawn(pos, vel, model, is_c4)
{
	grenade = spawn("script_model", pos);
	grenade setmodel(model);
	grenade thread sr\libs\portal\_physics::startGrenadePhysics(vel * 20, is_c4);
	grenade thread watchdetonation();

	return grenade;
}

watchDetonation()
{
	self endon("delete");
	self endon("physics_stop");
	self waittill("remove");

	if (isDefined(self.originalGrenade))
		self.originalGrenade show();
	self delete();
	self notify("delete");
}

grenadeWatchExplosionForTurrets(restTime)
{
	self endon("delete");
	self endon("disconnect");
	self endon("death");

	wait restTime;

	explosionRadiusDamageTurrets(self.origin , 200, 700, 100);

}

c4watchExplosionForTurrets(player)
{
	player endon("disconnect");
	player endon("death");
	player waittill("detonate");

	explosionRadiusDamageTurrets(self.origin , 200, 600, 100);
}

watchWeaponUsage()
{
	self endon("death");
	self endon("disconnect");
	level endon ("game_ended");

	for (;;)
	{
		self waittill ("weapon_fired");

		if (!getdvarint("portal_block_bullet"))
			self thread watchCurrentFiringForPortals();
	}
}

watchCurrentFiringForPortals()
{
	weapon = self getcurrentweapon();

	max_dmg_range = 4000;
	if (!max_dmg_range)
		return;
	max_checkrange = 2.5 * max_dmg_range;

	if (weapon == "deserteagle_mp" || weapon == "deserteaglegold_mp")
		max_checkrange = 3000;
	if (max_dmg_range > 4000)
		max_checkrange = 4000;

	angle_vec = anglestoforward(self getplayerangles());

	for (n = 0; n < level.portal_turrets.size; n++)
	{
		if (!level.portal_turrets[n].health)
			continue;

		p = level.portal_turrets[n].center;
		eyepos = self eyepos();
		vec = eyepos - p;

		if (sign(vectordot(vec, angle_vec)) == -1)
		{
			length = vectordot(p - eyepos, angle_vec);
			range_left = max_checkrange - length;

			if (range_left < 0)
				continue;

			vecx2 = distancesquared(p, (eyepos + length * angle_vec));

			if (vecx2 < 20 * 20)
			{
				trace = bullettrace(eyepos, eyepos + angle_vec * (length + 10), true, self);
				if (isDefined(trace["entity"]) && (trace["entity"] == level.portal_turrets[n] || trace["entity"] == level.portal_turrets[n].wings[0] || trace["entity"] == level.portal_turrets[n].wings[1]))
				{
					self maps\mp\gametypes\_damagefeedback::updateDamageFeedback(false);
					damage = calculateWeaponDamage(weapon, length, max_dmg_range);
					trace["entity"] notify("damage", damage, self);
					return;
				}
			}
		}
	}
	for (n = 0; n < level.portals.size; n++)
	{
		if (!level.portals[n].active)
			continue;

		p1 = level.portals[n].trace;

		eyepos = self eyepos();
		vec = eyepos - p1["position"];

		w_normal = p1["normal"];
		r = p1["right"];
		u = p1["up"];

		if (sign(vectordot(vec, w_normal)) == 1 && sign(vectordot(vec, angle_vec)) == -1)
		{
			length = vectordot(vec ,w_normal) / vectordot(w_normal * -1, angle_vec);

			range_left = max_checkrange - length;
			if (range_left < 0)
				continue;

			wallpos = eyepos + angle_vec*(length);
			portaltowallpos = wallpos - p1["position"];
			x = vectordot(portaltowallpos, r);
			y = vectordot(portaltowallpos, u);

			if (isInPortal(x, y, -12, -12))
			{
				if (physicstrace(eyepos, wallpos + w_normal * 2) != (wallpos + w_normal * 2))
					continue;

				p2 = level.portals[n].otherportal.trace;

				pos = p2["fx_position"] + x * p2["right"] * -1 + y * p2["up"];
				forward = vectordot(angle_vec, r * -1) * p2["right"] + vectordot(angle_vec, u) * p2["up"] + vectordot(angle_vec, w_normal * -1) * p2["normal"];

				self thread shootOutPortal(pos, forward, length, range_left, max_dmg_range, weapon);
				return;
			}
		}
	}
}

shootOutPortal(pos, vec, range_travelled, range_left, max_dmg_range, weapon)
{
	trace = bullettrace(pos, pos + vec*range_left, true, undefined);

	if (trace["fraction"] == 1)
		return;

	if (isDefined(trace["entity"]))
	{
		damage = calculateWeaponDamage(weapon, range_travelled + range_left*trace["fraction"], max_dmg_range);
		trace["entity"] damageEnt(self, damage, "MOD_PISTOL_BULLET", weapon, trace["position"], vec);
	}
	wait 0.05;

	playImpactFX(trace["surfacetype"], trace["position"], trace["normal"]);
}

calculateWeaponDamage(weapon, range_travelled, max_dmg_range)
{
	return 50;
}

calculateDamageFraction(range_travelled, max_dmg_range, min_dmg_range, min_dmg_fraction)
{
	x = (min_dmg_range - range_travelled) / (min_dmg_range - max_dmg_range);
	if (x > 1)
		x = 1;
	if (x < 0)
		x = 0;
	return ((min_dmg_fraction) + (1 - min_dmg_fraction) * x);
}

playImpactFX(surfacetype, pos, vec)
{

}

explosionRadiusDamageTurrets(pos, radius, max_dmg, min_dmg)
{
	for (i = 0; i < level.portal_turrets.size; i++)
	{
		if (!level.portal_turrets[i].alive)
			continue;
		if (distancesquared(pos, level.portal_turrets[i].center) > radius*radius)
			continue;

		s = level.portal_turrets[i] sightconetrace(pos, level.players[0]);
		damage = max_dmg * s * calculateDamageFraction(distance(pos, level.portal_turrets[i].center), radius * 0.25, radius, min_dmg / max_dmg);

		level.portal_turrets[i] notify("damage", int(damage), self, "MOD_EXPLOSIVE");
	}
}

explosionRadiusDamage(pos, radius, max_dmg, min_dmg, ignore_ents)
{
	if (!isDefined(ignore_ents))
		ignore_ents = [];

	ents = getentarray("destructable", "targetname");
	for (i = 0; i < ents.size; i++)
	{
		if (distancesquared(pos, ents[i].origin) > radius*radius)
			continue;

		trace = traceArray(pos, ents[i].origin + (0, 0, 20), false, ignore_ents);

		if (!isDefined(trace["entity"]) || trace["entity"] != ents[i])
			continue;

		damage = max_dmg * calculateDamageFraction(distance(pos,trace["position"]), radius * 0.25, radius, min_dmg / max_dmg);
		ents[i] damageEnt(self, damage, "MOD_EXPLOSIVE", "", trace["position"], trace["position"] - pos);
	}
	for (i = 0; i < level.players.size; i++)
	{
		if (distancesquared(pos, level.players[i].origin) > radius * radius)
			continue;

		player_center = level.players[i].origin + level.players[i] getcenter();
		trace = traceArray(pos, player_center, false, ignore_ents);

		if (distancesquared(pos, trace["position"]) < (distancesquared(pos, player_center) - 8 * 8))
			continue;

		damage = max_dmg * calculateDamageFraction(distance(pos, player_center), radius * 0.25, radius, min_dmg / max_dmg);
		level.players[i] damageEnt(self, damage, "MOD_EXPLOSIVE", "", trace["position"], trace["position"] - pos);
	}
}

damageEnt(eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir)
{

	if (!isDefined(self))
		return;

	if (iDamage <= 0)
		iDamage = 1;

	iDamage = int(iDamage);

	if (isplayer(eAttacker) && ((isDefined(self.teamKill) && self.teamKill) || isplayer(self)))
		eAttacker maps\mp\gametypes\_damagefeedback::updateDamageFeedback(false);

	if (isplayer(self))
	{
		shitloc = "body";
		if (distancesquared(self eyepos(), vPoint) < 16 * 16 && sMeansofDeath != "MOD_EXPLOSIVE" && sMeansofDeath != "MOD_GRENADE")
		{
			shitloc = "head";
			iDamage = int(iDamage * 1.4);
		}

		self thread finishPlayerDamageWrapper(eAttacker, eAttacker, iDamage, 0, sMeansOfDeath, sWeapon, vPoint, vDir, shitloc, 0);

		if (self.health - iDamage <= 0)
			return true;
	}
	else
		self notify("damage", iDamage, eAttacker, vDir, vPoint, sMeansOfDeath, "", "");

	return false;
}

finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if (sMeansOfDeath == "MOD_EXPLOSIVE" || sMeansOfDeath == "MOD_GRENADE")
		self shellShock("damage_mp", 0.2);
	else if (sMeansOfDeath != "TURRET_BULLET")
		self shellShock("damage_mp", 0.05);
	else
		sMeansOfDeath = "MOD_RIFLE_BULLET";

	self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);

	self maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
}

#include sr\sys\_dvar;
#include sr\sys\_events;
#include sr\utils\_math;
#include sr\utils\_common;

main()
{
	level.turrets_allow = addDvar("portal_allow_turrets", "portal_allow_turrets", 1, 0, 1, "int");
	level.portal_turrets = [];

	precache();
}

precache()
{
	preCacheModel("turret");
	preCacheModel("turret_wing0");
	preCacheModel("turret_wing1");
	preCacheModel("turret_broken");
	preCacheModel("turret_wing0_broken");
	preCacheModel("turret_wing1_broken");

	level.fx["turret_flash"] = loadfx("portal/turret_flash");
	level.fx["turret_light_flash"] = loadfx("portal/turret_light_flash");
	level.fx["turret_explode"] = loadfx("portal/turret_explosion");
	level.fx["turret_sparks_pop"] = loadfx("portal/turret_sparks_pop");
	level.fx["turret_sparks"] = loadfx("portal/turret_sparks");
	level.fx["turret_cookoff"] = loadfx("portal/turret_cookoff");

	level.turret_killed_player_this_frame = false;
}

turret()
{
	self endon("disconnect");
	self endon("death");

	if (!getdvarint("portal_allow_turrets"))
	{
		self iprintln("Turrets not allowed");
		return;
	}
	if (self.turrets.size >= getdvarint("portal_max_turrets"))
	{
		self notify("place_turret");

		if (isDefined(self.test_turret))
			self.test_turret delete();

		self iprintln("You cannot spawn any more turrets");
		return;
	}
	if (!isDefined(self.test_turret))
	{
		eye = self eyepos();
		angles = self getPlayerAngles();

		pos = eye + anglestoforward(angles) * (15 + level.pickup_object_distance + 17) - (0, 0, 30);
		self.test_turret = spawn("script_model", pos);
		self.test_turret setmodel("turret");
		self.test_turret hidepart("tag_eye");

		self endon("death");
		self endon("disconnect");
		self endon("place_turret");

		old_eye = (0, 0, 0);
		old_ang = (0, 0, 0);

		while (true)
		{
			eye = self eyepos();
			angles = self getPlayerAngles();

			if (eye!=old_eye || angles!=old_ang)
			{
				self.test_turret moveto(playerphysicstrace(eye, eye + anglestoforward(angles)
					* (15 + level.pickup_object_distance + 17) - (0, 0, 30)), 0.1);
				self.test_turret rotateto((0, angles[1], 0), 0.1);
			}

			old_eye = eye;
			old_ang = angles;
			wait 0.1;
		}
	}
	else
	{
		players = getAllPlayers();
		for (i = 0; i < players.size; i++)
		{
			pos1 = players[i].origin;
			pos2 = self.test_turret.origin;
			if (distancesquared((pos1[0], pos1[1], 0), (pos2[0], pos2[1], 0)) < 37 * 37
				&& pos2[2] - pos1[2] > -40 && pos2[2] - pos1[2] < 60)
			{
				self iprintln("turret too close to player");
				return;
			}
		}
		self notify("place_turret");
		self.turrets[self.turrets.size] = self thread turretSpawn(self.test_turret.origin, self.test_turret.angles);
		self.test_turret delete();
	}
}

turretSpawn(pos, angles)
{
	if (getentarray().size > 700)
	{
		println("too many turrets spawned, deleting old turrets");
		level.portal_turrets[0] turretDelete();
	}

	angles = (angles[0], angles[1], 0);
	pos = bullettrace(pos, pos + (0,0,-1000), false, undefined)["position"];

	if (!isDefined(pos))
		return;

	turret = sr\libs\portal\_portal::portalSpawn("turret", (pos[0], pos[1], pos[2]), angles, "cylinder", 10, 0.3, 0.25, true, 0.1, 20);
	turret.physics["pickup_script"] = ::pickup;

	if (isDefined(self))
		turret.owner = self;

	turret.forward = anglestoforward(angles);
	turret.up = anglestoup(angles);
	turret.center = pos + turret.forward * 5 + turret.up * 34;
	turret.speed = 0.15;
	turret.swayspeed = turret.speed * 8;
	turret.searchtime = 4.5;
	turret.shootspeed = 0.1;
	turret.damage = 3;
	turret.explosionradius = 220;
	turret.explosiondamage = 70;
	turret.activatespeed = 0.5;
	turret.maxdist = 1100;
	turret.degreex = 60;
	turret.degreey = 50;
	turret.targettime = turret.speed * 4;
	turret.defaultangles = angles;
	turret.angles = angles;
	turret.aim = spawn("script_origin", turret gettagorigin("tag_aim"));
	turret.aim hide();
	turret.aim.angles = angles;
	turret.eyepos = turret gettagorigin("tag_eye");

	turret.wings = [];
	turret.physics["ignore_ents"] = [];
	for (i = 0; i < 2; i++)
	{
		turret.wings[i] = spawn("script_model", turret gettagorigin("tag_aim"));
		turret.wings[i] setmodel("turret_wing" + i);
		turret.wings[i].angles = angles;
		turret.wings[i] linkto(turret.aim);
		turret.wings[i] hide();
		turret.wings[i] setcontents(1);
		turret.wings[i].physics["name"] = "turret_wing" + i;
		turret.physics["ignore_ents"][i] = turret.wings[i];
	}
	turret.physics["ignore_ents"][2] = turret;
	turret.targets = [];
	turret.isturret = true;
	turret.active = false;
	turret.alive = true;
	turret.activating = false;
	turret.isturret = true;
	turret.exploding = false;
	turret.firing = false;
	turret.shouttimeover = true;
	turret.shotat = false;
	turret.health = 500;
	turret.teamKill = true;

	turret thread damagelistener(turret);
	turret.wings[0] thread damagelistener(turret);
	turret.wings[1] thread damagelistener(turret);

	turret playloopSound("turret_loop");
	turret thread sleep();

	level.portal_turrets[level.portal_turrets.size] = turret;
	return turret;
}

damageListener(turret)
{
	turret endon("picked_up");
	turret endon("destroyed");
	turret endon("delete");

	while (true)
	{
		self waittill("damage", damage, player, this, nthat , meansofdeath);

		if (!isDefined(meansofdeath))
			meansofdeath = "";

		turret.health -= damage;
		if (turret.health < 0)
			turret.health = 0;

		if (turret.health == 0)
			turret thread explode(meansofdeath);
		else
		{
			if (meansofdeath != "MOD_EXPLOSIVE")
			{
				if (randomint(2))
					turret thread shoutHurt();
				if (!randomint(15))
					playfx(level.fx["turret_sparks"], turret gettagorigin("tag_wing" + randomint(2)));
			}
			if (turret.active)
			{
				if (isDefined(player))
					if (IndexOf(turret.targets, player) >= 0)
						turret thread target(player);
			}
			else
			{
				turret.wakeup_means = meansofdeath;
				turret thread activate(1);
			}
		}
	}
}

shoutHurt()
{
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");

	if (self.shouttimeover && !self.activating && !self.firing)
	{
		self playsound("turret_hurt");
		self.shouttimeover = false;
		self thread resetshouttime(2.2 + randomfloat(2));
	}
	self.shotat = true;
	self.swayspeed = self.speed * 4;

	self notify("shot_taken");
	self endon("shot_taken");

	startledtime = 1.5;

	wait startledtime;
	self.swayspeed = self.speed * 8;
	wait (self.searchtime + 0.3 - startledtime);
	self.shotat = false;
}

resetShoutTime(time)
{
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");

	wait time;
	self.shouttimeover = true;
}

explode(meansofdeath)
{
	self endon("delete");

	self.exploding = 1;
	self.alive = 0;

	self notify("destroyed");
	self playsound("turret_ignite");
	playfx(level.fx["turret_explode"], self.center);

	wait 0.05;

	ignore_ents[0] = self;
	ignore_ents[1] = self.wings[0];
	ignore_ents[2] = self.wings[1];

	sr\libs\portal\_weapons::explosionRadiusDamage(self.center+self.up * 40, self.explosionradius, self.explosiondamage, 10, ignore_ents);

	self setmodel("turret_broken");
	self.wings[0] setmodel("turret_wing0_broken");
	self.wings[1] setmodel("turret_wing1_broken");

	if (meansofdeath != "MOD_EXPLOSIVE")
	{
		if (randomintrange(0,5))
		{
			wait randomfloat(1.5);
			self playsound("turret_sparks");
			playfx(level.fx["turret_sparks_pop"], self gettagorigin("tag_wing0"));
			playfx(level.fx["turret_sparks_pop"], self gettagorigin("tag_wing1"));
		}
		else
		{
			wait 0.05;
			self playsound("turret_cookoff");
			playfx(level.fx["turret_cookoff"], self.center);
			wait 0.1;
			self playsound("turret_sparks");
		}
	}
	if (self.active)
	{
		wait (0.5 + randomfloat(1));

		self playsound("turret_hurt_explosion");

		if (randomint(3))
		{
			wait (1 + randomfloat(1.5));
			self playsound("turret_destroyed");
			self deactivate(true);
		}
	}
	else
	{
		wait 1.5;
		self playsound("turret_destroyed");
	}

	self stoploopsound();
	self hidepart("tag_eye");

	self.active = 0;
	self.exploding = 0;
	self.destroyed = 1;

	turrets = [];

	for (i = 0; i < level.portal_turrets.size; i++)
	{
		if (level.portal_turrets[i] == self)
			continue;
		if (distancesquared(self.center, level.portal_turrets[i].center) < 600 * 600)
			turrets[turrets.size] = level.portal_turrets[i];
	}
	wait 1.2;

	thread turretsTaunt(turrets, 0);
}

turretsTaunt(turrets, idx)
{
	if (!isDefined(turrets[idx]))
		return;

	if (turrets[idx].alive && !turrets[idx].active && !turrets[idx].activating && !randomint(3))
	{
		turrets[idx] playsound("turret_witnessdeath");
		wait 1.5 + randomfloat(1);
	}
	thread turretsTaunt(turrets, idx + 1);
}

updateTargets()
{
	self.targets = [];
	players = getAllPlayers();

	for (i = 0; i < players.size; i++)
	{
		if (!getdvarint("portal_turret_target_owner") && players[i] == self.owner)
			continue;

		d2 = distancesquared(players[i].origin, self.aim.origin);
		if (d2 < self.maxdist * self.maxdist && players[i].health > 0)
		{
			if (d2 < 80 * 80)
				aim_position = players[i] centerpos();
			else
				aim_position = players[i] eyepos();

			angles = vectortoangles(aim_position - self.aim.origin);

			if (abs(angleNormalize(self.defaultangles[0] - angles[0])) < self.degreex && abs(angleNormalize(self.defaultangles[1] - angles[1])) < self.degreey)
			{
				if (players[i] SightConeTrace(self.eyepos, self) || players[i].portal["forceturretshoot"])
					self.targets[self.targets.size] = players[i];
			}
		}
	}
}

sleep()
{
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");
	self endon("activated");

	self hidepart("tag_eye");

	while (!self.targets.size)
	{
		self updatetargets();
		wait self.targettime;
	}
	self thread activate(0);
}

activate(woken_up)
{
	if (self.active || self.activating)
		return;

	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");
	self notify("activated");

	self.activating = true;
	self hidepart("tag_aim");
	self showpart("tag_eye");

	for (i = 0; i < self.wings.size; i++)
	{
		self.wings[i] unlink();
		self.wings[i] setmodel("turret_wing" + i);
		self.wings[i] show();
		self.wings[i] moveto(self gettagorigin("tag_wing" + i), self.activatespeed);
	}

	self playsound("turret_active_sound");
	if (randomintrange(0,4) && !woken_up)
		self playsound("turret_active");

	self playsound("turret_deploy");

	wait self.activatespeed;
	for (i = 0; i < self.wings.size; i++)
		self.wings[i] linkto(self.aim);


	self.activating = false;
	self.active = 1;

	self playsound("turret_ping");

	wait 0.3;

	self thread deploying(woken_up);
}

deploying(woken_up)
{
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");

	self.killedtarget = false;
	self.losttarget = true;

	self updatetargets();
	self.last_target = self;

	for (;;)
	{
		if (!level.turret_killed_player_this_frame)
			self.losttarget = true;

		self updatetargets();

		if (!self.targets.size)
			break;

		target = self.targets[randomint(self.targets.size)];
		self target(target);
	}
	self.firing = 0;

	if ((self.killedtarget || level.turret_killed_player_this_frame) || (!self.losttarget && !woken_up))
	{
		wait 0.2;
		self setangles(self.defaultangles, 0.2);
		wait 0.1;
		if (self.killedtarget)
			self playsound("turret_retire");
		wait 0.1;
		self thread deactivate();
	}
	else
	{
		if (woken_up && !self.losttarget)
		{
			self playsound("turret_woken_up");
			self thread searchmode(0);
		}
		else
			self thread searchmode(1);
	}
}

target(player)
{
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");

	self notify("stop_target");
	self endon("stop_target");
	player endon("death");
	player endon("disconnect");

	if (player != self.last_target)
		wait self.speed;

	self.last_target = player;
	self.killedtarget = false;
	self.losttarget = false;

	self thread loopShoot(player);
	count = self.targettime / self.speed;

	for (i = 0; i < count && isAlive(player) && player.sessionstate == "playing" && player.health > 0; i++)
	{
		d2 = distancesquared(player.origin, self.aim.origin);
		if (d2 < 80 * 80)
			aim_position = player centerpos();
		else
			aim_position = player eyepos();

		if (!self setangles(vectortoangles(aim_position - self.aim.origin)))
		{
			self.losttarget = true;
			self notify("stop_target");
		}
		wait self.speed;
	}
	self notify("stop_target");
}

loopShoot(player)
{
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");

	self endon("stop_target");
	player endon("death");
	player endon("disconnect");

	self.firing = 1;

	while (true)
	{
		eye = player eyepos();
		dir = anglestoforward(self.aim.angles);

		for (n = 0; n < 2; n++)
		{
			for (i = 0; i < 2; i++)
			{
				pos = self.wings[n] gettagorigin("tag_flash" + i);
				playfx(level.fx["turret_flash"], pos, dir + (vectorRandom(2) / 1000));
			}
		}
		self playSound("turret_fire");
		playfx(level.fx["turret_light_flash"], self.eyepos);

		trace = traceArray(self.eyepos, self.eyepos + dir*self.maxdist, true, self.physics["ignore_ents"]);
		killed_ent = false;

		if (trace["fraction"] != 1)
		{
			if (isplayer(trace["entity"]))
				playSoundOnPosition("bullet_small_" + trace["surfacetype"], trace["position"]);
			else
				sr\libs\portal\_weapons::playImpactFX(trace["surfacetype"], trace["position"], trace["normal"]);

			if (isDefined(trace["entity"]))
			{
				range_travelled = self.maxdist * trace["fraction"];
				max_dmg_range = (self.maxdist / 2);

				damagefraction = sr\libs\portal\_weapons::calculateDamageFraction(range_travelled, max_dmg_range, max_dmg_range * 1.25, 0.5);

				damage = self.damage * damagefraction;

				if (!isplayer(trace["entity"]))
					damage *= 15;

				killed_ent = trace["entity"] sr\libs\portal\_weapons::damageEnt(self, int(damage), "TURRET_BULLET", "", trace["position"], dir);
			}
		}
		if (!isDefined(trace["entity"]) || isDefined(trace["entity"]) && trace["entity"] != player)
		{
			if (distancesquared(self.aim.origin, trace["position"]) > distancesquared(self.aim.origin, eye))
			{
				player_distance = vectordot(eye - self.aim.origin, dir);
				sight_pos = self.aim.origin + player_distance * dir;
				if (distancesquared(eye, sight_pos) < 32 * 32)
				{
					damage = self.damage * 0.25 * sr\libs\portal\_weapons::calculateDamageFraction(player_distance, self.maxdist * 0.5, self.maxdist * 0.625, 0.5);
					self.killedtarget = player sr\libs\portal\_weapons::damageEnt(self, int(damage), "TURRET_BULLET", "", sight_pos, dir);
				}
			}
		}
		else
			self.killedtarget = killed_ent;

		if (self.killedtarget)
		{
			level.turret_killed_player_this_frame = true;
			thread resetplayerkilledvar();
		}
		wait self.shootspeed;
	}
}

resetPlayerKilleDvar()
{
	wait 0.1;
	level.turret_killed_player_this_frame = false;
}

searchMode(play_sound)
{
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");

	self thread sway();
	checkspeed = 0.1;

	for (i = 0; ((i < self.searchtime/checkspeed) || self.shotat) && !self.targets.size; i++)
	{
		wait checkspeed;
		self updatetargets();
		if (i == 18 && !self.targets.size && play_sound && !(isDefined(self.wakeup_means) && self.wakeup_means == "MOD_EXPLOSIVE"))
			self playsound("turret_search");
	}

	self notify("end_search");
	if (self.targets.size)
		self thread deploying(0);
	else
		self thread deactivate();
}

sway()
{
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");
	self endon("end_search");

	wait self.speed;

	x_0 = int(self.degreex*0.3);
	x_1 = int(self.degreex*-0.35);
	y = int(self.degreey*0.7);

	while (true)
	{
		self setangles(self.defaultangles + (randomintrange(x_1, x_0), y, 0), self.swayspeed);
		wait self.swayspeed;
		y *= -1;
	}
}

deactivate(destroyed)
{
	self endon("picked_up");
	self endon("destroyed");
	self endon("delete");

	self notify("stop_target");
	self playsound("turret_retract");
	self setangles(self.defaultangles);
	wait self.speed + 0.05;

	for (i = 0; i < self.wings.size; i++)
	{
		self.wings[i] unlink();
		self.wings[i] moveto(self gettagorigin("tag_aim"), self.activatespeed);
	}
	wait self.activatespeed;

	self showpart("tag_aim");
	for (i = 0; i < self.wings.size; i++)
	{
		self.wings[i] hide();
		self.wings[i] linkto(self.aim);
	}
	wait 0.05;

	self.active = 0;
	if (isDefined(destroyed) && destroyed)
		self notify ("destroyed");
	else
		self thread sleep();
}

setAngles(angles, time)
{
	if (!isDefined(time))
		time = self.speed;

	angles = (angleNormalize(angles[0]), angleNormalize(angles[1]), 0);

	new_degree_x = angleNormalize(self.defaultangles[0] - angles[0]) * -1;
	new_degree_y = angleNormalize(self.defaultangles[1] - angles[1]) * -1;

	x_ok = abs(new_degree_x) <= self.degreex;
	y_ok = abs(new_degree_y) <= self.degreey;

	if (!x_ok)
		new_degree_x = sign(new_degree_x) * self.degreex;
	if (!y_ok)
		new_degree_y = sign(new_degree_y) * self.degreey;

	self.aim rotateto(self.defaultangles + (new_degree_x, new_degree_y, 0), time);

	return (x_ok && y_ok);
}

turretDelete()
{
	self notify("delete");

	newarray = [];
	for (i = 0; i < level.portal_turrets.size; i ++)
	{
		if (level.portal_turrets[i] == self)
			continue;
		newarray[newarray.size] = level.portal_turrets[i];
	}
	level.portal_turrets = newarray;

	self.aim delete();
	self.wings[0] delete();
	self.wings[1] delete();
	self delete();
}

pickup(player)
{
	self notify("picked_up");
	self unlink();

	self showpart("tag_eye");
	self setcontents(0);
	self hidepart("tag_aim");

	for (i = 0; i < self.wings.size; i++)
	{
		self.wings[i] unlink();
		self.wings[i] setmodel("turret_wing"+i);
		self.wings[i] show();
		self.wings[i] setcontents(0);
		self.wings[i].origin = self gettagorigin("tag_wing" + i);
	}
	self playsound("turret_pickup_" + randomintrange(1,11));
	self.active = 0;
	self thread followPlayer();
}

followPlayer(player)
{
	self notify("physics_stop");
	self endon("unlink");

	old_eye = (0, 0, 0);
	old_ang = (0, 0, 0);

	player = self.physics["owner"];
	angle_offset = self.angles[1] - player getPlayerAngles()[1];

	self.physics["sway"] = false;
	self.physics["sway_offset"] = (0, 0, 0);

	random_pos = (0, 0, 0);
	skip_arm_sway = 0;
	pos = self.origin;

	while (true)
	{
		eye = player eyepos();
		angles = player getPlayerAngles();

		if (eye != old_eye || angles != old_ang)
		{
			self.physics["sway"] = false;

			forward = anglestoforward(angles);
			pos = playerphysicstrace(self.origin - (0, 0, 20),
				eye - (0, 0, 20) + forward * (15 + level.pickup_object_distance + 17));
			pos+= self.physics["sway_offset"];
			forward = anglestoforward((angles[0], angles[1] + angle_offset,angles[2]));

			r = vectorprod(forward, (0, 0, 1));
			f = vectorprod((0, 0, 1), r);

			self moveto(pos , 0.1);
			self rotateto((0, angles[1] + angle_offset, 0), 0.1);

			self.wings[0] moveto(pos + r * -6 + f * 4 + (0, 0, 3.4), 0.1);
			self.wings[1] moveto(pos + r * 6 + f * 4 + (0, 0, 3.4), 0.1);
		}
		else
			self.physics["sway"] = true;

		if (skip_arm_sway)
		{
			if (randomintrange(0, 4))
				random_pos = (randomintrange(int(self.degreex * -0.5),
					int(self.degreex * 0.5)), randomintrange(int(self.degreey * -0.5), int(self.degreey * 0.5)), 0);
			skip_arm_sway++;
		}
		else
			skip_arm_sway--;

		self.wings[0] rotateto(random_pos + (0, angle_offset+angles[1], 0), 0.2, 0.05, 0.05);
		self.wings[1] rotateto(random_pos + (0, angle_offset+angles[1], 0), 0.2, 0.05, 0.05);

		wait 0.1;
	}
}

swayPickup()
{
	self endon("unlink");

	old_sway = (0, 0, 0);
	for (i = 0;; i += 10)
	{
		self.physics["sway_offset"] = (cheapSin(i) * self.physics["sway_amount"],
			cheapSin(i + 90) * self.physics["sway_amount"], cheapSin(i * 2) * self.physics["sway_amount"] * 2);
		old_sway = self.physics["sway_offset"];

		if (self.physics["sway"])
			self moveto(self.origin + self.physics["sway_offset"] - old_sway, self.physics["sway_speed"] + 0.1);

		wait self.physics["sway_speed"];
		if (i >= 360)
			i -= 360;
	}
}

#include sr\libs\portal\_general;
#include sr\libs\portal\_hud;
#include sr\libs\portal\_portal;
#include sr\utils\_common;
#include sr\sys\_events;

main()
{
	menu("portal", "blue", ::menu_Portal);
	menu("portal", "red", ::menu_Portal);
	menu("portal", "pickup", ::menu_Pickup);
	menu("portal", "turret", ::menu_Turret);
}

menu_Portal(arg)
{
	if (self getCurrentWeapon() != level.portalgun)
		return;
	if (self isOnLadder() || self isMantling() || self.throwingGrenade)
		return;

	self thread fire();
	self playLocalSound("portal_gun_shoot_" + response);
	self thread portal(response);
	wait 0.3;
}

menu_Pickup(arg)
{
	if (self getCurrentWeapon() != level.portalgun_bendi)
		return;
	if (self isOnLadder() || self isMantling() || self.throwingGrenade)
		return;

	self thread portal\_pickup::pickup_init();
}

menu_Turret(arg)
{
	if (self isOnLadder() || self isMantling() || self.throwingGrenade)
		return;

	self thread turret();
}

resetPortals()
{
	self notify("Deactivate_Portals");

	self thread delete_portal("blue");
	self thread delete_portal("red");

	self thread updatehud("default");
}

stopAll(delete_portals, disconnected)
{
	if (delete_portals)
	{
		self notify("Deactivate_Portals");

		self thread Delete_Portal("blue");
		self thread Delete_Portal("red");

		self notify("place_turret");
		if (isDefined(self.test_turret))
			self.test_turret delete();

		for (i = 0; i < self.turrets.size; i++)
			self.turrets[i] portal\_turret::turretDelete();

		self.turrets = [];
	}

	self notify("stop_watch_button");
	self notify("stop_watch_fps");

	if (isDefined(disconnected))
		return;

	if (self getstat(level.portal_options_num) == 2)
		self _exec("bind mouse1 +attack;bind mouse2 +speed_throw;");
	else
		self _exec("bind mouse1 +attack;bind mouse2 +toggleads_throw;");

	if (self hasweapon(level.portalgun) && !delete_portals)
		self setweaponammoclip(level.portalgun, 0);

	self allowads(true);
	self.portal["inzoom"] = false;
	self.portal["can_use"] = false;

	self thread updatehud("none");
	self notify("stopAll");
}

fire()
{
	self endon("disconnect");
	self endon("death");

	weap = self getcurrentweapon();
	self setweaponammoclip(weap, 1);
	self _exec("-attack;+attack;-attack");
}

turret()
{
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
		for (i = 0; i < level.players.size; i++)
		{
			pos1 = level.players[i].origin;
			pos2 = self.test_turret.origin;
			if (distancesquared((pos1[0], pos1[1], 0), (pos2[0], pos2[1], 0)) < 37 * 37
				&& pos2[2] - pos1[2] > -40 && pos2[2] - pos1[2] < 60)
			{
				self iprintln("turret too close to player");
				return;
			}
		}
		self notify("place_turret");
		self.turrets[self.turrets.size] = self thread portal\_turret::turretSpawn(self.test_turret.origin, self.test_turret.angles);
		self.test_turret delete();
	}
}

portal(color)
{
	othercolor = othercolor(color);

	eye = self eyepos();
	forward = anglesToForward(self getPlayerAngles()) * level.maxdistance;
	trace = traceArray(eye, eye + forward, false, level.portalobjects);

	if (trace["fraction"] == 1)
		portalfailed = true;
	else
		portalfailed = false;

	if (!portalfailed)
	{
		portalfailed = true;
		for (i = 0; i < level.portalSurfaces.size; i++)
			if (trace["surfacetype"] == level.portalSurfaces[i])
				portalfailed = false;
	}

	terrain = !getdvarint("portal_forbid_terrain");
	oldpos = trace["position"];
	pos = oldpos;
	normal = trace["normal"];
	angles = vectortoangles(normal);

	on_ground = false;
	on_terrain = false;

	if (abs(round(normal[2], 3 - terrain)) == 1)
		on_ground = true;

	if (on_ground )
		angles = (angles[0], self getPlayerAngles()[1] - 180, 0);

	right =	anglestoright(angles);
	up = anglestoup(angles);

	if (!portalfailed)
	{
		slope_increase = abs(normal[2])*3 * !on_ground;

		width = level.portalwidth;
		height = level.portalheight + slope_increase;

		if (on_ground)
			width = height * 0.8;

		forward = normal * (1 + terrain*5*on_ground);
		backward = forward * -1;

		portals = [];

		for (i = 0; i < level.portals.size; i++)
		{
			if (isDefined(self.portal[color]))
				if (self.portal[color] == level.portals[i])
					continue;

			p = level.portals[i].trace["position"];
			q = pos;

			vec = pos - level.portals[i].trace["position"];

			a = level.portals[i].trace["right"];
			b = level.portals[i].trace["up"];
			c = level.portals[i].trace["normal"];

			trans = (vectordot(vec, a), vectordot(vec, b), vectordot(vec, c));

			if (!(round(trans[2], -1)))
			{
				x = abs(trans[0]);
				y = abs(trans[1]);
				if (x < 2 * width && y < 2 * height)
					portals[portals.size] = level.portals[i];

				if (x < width && y < height)
				{
					if (y < x * (height / width))
						pos = p + b * trans[1] + a * width * sign(trans[0]);
					else
						pos = p + a * trans[0] + b * height * sign(trans[1]);

					if (traceArray(p + forward, pos + forward, false, level.portalobjects)["fraction"] != 1)
					{
						portalfailed = true;
						break;
					}
				}
			}

		}

		vec = [];
		vec[1] = up*(1+(height/2));
		vec[2] = vec[1] * -1;
		vec[3] = right*(1+(width/2))*-1;
		vec[4] = vec[3] * -1;

		a = 0.8;

		vec[5] = (vec[1] + vec[3]) * a;
		vec[6] = vec[5] * -1;
		vec[7] = (vec[1] + vec[4]) * a;
		vec[8] = vec[7] * -1;

		failed = [];
		vital_dir = [];

		for (i = 1; i < 9; i++)
		{
			vital_dir[i] = [];
			failed[i] = false;
		}
		for (i = 2; i < 9; i += 2)
			vital_dir[i][0] = i - 1;

		vital_dir[5][0] = 2;
		vital_dir[5][1] = 4;
		vital_dir[6][1] = 1;
		vital_dir[6][2] = 3;
		vital_dir[7][0] = 2;
		vital_dir[7][1] = 3;
		vital_dir[8][1] = 1;
		vital_dir[8][2] = 4;

		updated_pos = pos;
		second_check = false;

		for (i = 1; i < 9 && !portalfailed; i++)
		{
			hit = 1 - traceArray(pos + forward, pos + forward + vec[i], false, level.portalobjects)["fraction"];

			if (!hit)
			{
				tmp_ground_trace = traceArray(pos + forward + vec[i], pos + backward + vec[i], false, level.portalobjects);
				if (tmp_ground_trace["fraction"] == 1)
					hit = traceArray(pos + backward + vec[i], pos + backward, false, level.portalobjects)["fraction"];
				if (hit == 1)
					portalfailed = true;

				if (!on_terrain && on_ground && tmp_ground_trace["fraction"] == 1)
					on_terrain = normal != tmp_ground_trace["normal"];
			}

			if (hit)
			{
				if (!on_ground || (on_ground && second_check))
				{
					for (j = 0; j < vital_dir[i].size; j++)
					{
						if (failed[vital_dir[i][j]])
							portalfailed = true;
					}
				}

				failed[i] = true;
				if (portalfailed)
					break;

				updated_pos -= vec[i] * (hit + 0.02);

				if (i <= 4 && !second_check && !on_ground)
				{
					if ((failed[1] + failed[2] + failed[3] + failed[4]) >= 2)
					{
						pos = updated_pos;
						second_check = true; i = 0; continue;
						for (i = 1; i < 9; i++)
							failed[i] = false;
					}
				}
				else
					pos = updated_pos;
			}

			if (i == 4)
			{
				pos = updated_pos;
				if ((failed[1] + failed[2] + failed[3] + failed[4]) && !second_check)
				{
					second_check = true;
					i = 0;
					continue;
					for (i = 1; i < 9; i++)
						failed[i] = false;
				}
			}
		}

		for (i = 0; i < portals.size && !portalfailed; i++)
		{
			vec = pos - portals[i].trace["position"];
			a = portals[i].trace["right"];
			b = portals[i].trace["up"];
			x = vectordot(vec, a);
			y = vectordot(vec, b);
			if ((abs(x) < width - 1) && (abs(y) < height - 1))
				portalfailed = true;
		}
	}

	portal_out_pos = (0, 0, 0);
	safe_exit = (0, 0, 0);

	if (!portalfailed)
	{
		portal_out_pos = pos + normal * ((normal[2] >= 0) * (20 * (1 - normal[2])) + (-90 * normal[2]) * (normal[2] < 0));
		safe_exit = portal_out_pos - 30 * (1 - abs(normal[2])) * up;

		if (playerphysicstrace(safe_exit, safe_exit + normal) != (safe_exit + normal))
			portalfailed = true;
	}

	if (!portalfailed)
	{
		trace["position"] = pos;
		trace["fx_position"] = pos + normal * (1 + on_terrain * 2);
		trace["start_position"] = eye;
		trace["old_position"] = oldpos;
		trace["portal_out"] = portal_out_pos;
		trace["safe_exit"] = safe_exit;
		trace["on_ground"] = on_ground;
		trace["angles"] = angles;
		trace["right"] = right;
		trace["up"] = up;

		self portalCreate(color, trace);
	}
	else
	{
		self playLocalSound("portal_invalid_surface_player");

		if (trace["fraction"] != 1)
		{
			self playSoundOnPosition("portal_invalid_surface", trace["position"], true);
			if (!getdvarint("portal_disable_fancy_fx"))
				playfx(level._effect[color + "portal_fail"], trace["position"] + trace["normal"]);
		}
	}
}

portalDelete(color)
{
	for (i = 0; i < level.players.size; i++)
		if (level.players[i].portal["inportal"])
			level.players[i] freezecontrols(false);

	if (!self.portal[color + "_exist"])
		return;

	level notify("portal_rearange");

	self.portal[color] stoploopSound();
	self.portal[color] playSound("portal_close");
	self.portal[color] playSound("portal_close_" + color);
	self.portal[color] notify("stop_fx");

	if (!getdvarint("portal_disable_fancy_fx"))
		playfx(level._effect[color + "portal_close"], self.portal[color].trace["position"], self.portal[color].trace["normal"], self.portal[color].trace["up"]);

	self.portal[color].dummy delete();
	self.portal[color] delete();
	self.portal[color + "_exist"] = false;

	portalCleanArray(self.portal[color]);
}

portalCreate(color, trace)
{
	for (i = 0; i < level.players.size; i++)
		level.players[i].portal["inportal"] = false;


	self updatehud(color);
	self portalDelete(color);

	portal[color] = spawn("script_model", trace["fx_position"]);
	portal[color] setcontents(0);
	portal[color].angles = trace["angles"] + (180, 0, 0);
	portal[color].trace = trace;
	portal[color].color = color;
	portal[color].active = false;
	portal[color].dummy = spawn("script_model", trace["fx_position"]);
	portal[color].dummy.angles = trace["angles"];
	portal[color].dummy setcontents(0);
	portal[color].owner = self;

	self.portal[color] = portal[color];
	level.portals[level.portals.size] = self.portal[color];
	self.portal[color + "_exist"] = true;

	if (self.portal["blue_exist"] && self.portal["red_exist"])
		self thread portalActivate();

	portal[color] thread portalFX();
}

portalFX()
{
	self endon("stop_fx");

	oldpos = self.trace["old_position"];
	fxpos = self.trace["fx_position"];
	p = self.trace["start_position"];
	p += vectornormalize(oldpos - p) * 33;
	speed = 1500;

	t = length(fxpos - p) / speed * 1.5;
	if (t > 0.5)
		t = 0.5;

	self.bullet = spawn("script_model" , (-10000, 0, 0));
	self.bullet setmodel("collision_sphere");

	wait 0.05;

	playfxontag(level._effect["portalball"+self.color], self.bullet, "collision_sphere");

	angles = self.owner getplayerangles();

	f = anglestoforward(angles);
	u = anglestoup(angles);
	r = vectorprod(f,u);

	self.bullet moveCurve(self.owner eyepos() + f * 22 + u * -6 + r, oldpos, self.trace["position"], t);

	self thread playOpenSound(self.color, fxpos + self.trace["normal"] * 2);

	self hide();
	self setmodel("portal_" + self.color);

	self.dummy hide();
	self.dummy setmodel("portal_dummy_" + self.color);

	if (!getdvarint("portal_disable_fancy_fx"))
	{
		playfx(level._effect[self.color + "portal_open"], fxpos, self.trace["normal"], self.trace["up"]);
		wait 0.75;
	}
	if (getdvarint("portal_dummy_show_to_team") && isDefined(self.pers["team"]))
	{
		team = self.pers["team"];

		for (i = 0; i < level.players.size; i++)
			if (isDefined(level.players[i].pers["team"]) && (level.players[i].pers["team"] == team))
				self.dummy showtoplayer(level.players[i]);
	}
	else
		self.dummy showtoplayer(self.owner);

	self show();
	wait 0.6;
	self playloopSound("portal_ambient_loop");
}

playOpenSound(color, soundPos)
{
	self endon("stop_fx");

	wait 0.3;

	playSoundOnPosition("portal_open", soundPos);
	playSoundOnPosition("portal_open_" + self.color, soundPos);
}

moveCurve(p, q1, q2, t)
{
	self.origin = p;

	n = 6;
	curve = 1;

	if (t < 0.3)
	{
		n = 3;
		t *= 1.5;
	}

	vec1 = q1 - p;
	vec2 = q2 - q1;

	t /= n;

	vecx = (0, 0, 0);

	for (i = 1; i < n + 1 ; i++)
	{
		if (i != 1)
			wait t;
		fraction = exp(i / n, curve * 2);
		vec = vec2 * fraction + i * vec1 / n;
		vecx = vec;
		pos = p + vec;
		self moveto(pos, t);
	}
	self thread deleteFXAfterTime(t);
}

deleteFXAfterTime(t)
{
	wait t;
	self moveto((0, 0, 100000), 0.05);
	wait 0.1;
	self delete();
}

portalWait(color, othercolor)
{
	self endon("Deactivate_Portals");

	p1 = self.portal[color];
	p2 = self.portal[othercolor];

	self.portal[color].otherportal = self.portal[othercolor];

	c = ((0, 0, level.gravity) + (0, 0, 15)) * -0.05;

	while (true)
	{
		for (i = 0; i < level.players.size; i++)
		{
			if (getdvarint("portal_owner_walkthrough_only"))
				if (level.players[i] != self)
					continue;

			if (level.players[i].portal["inportal"])
				continue;

			player_on_ground = level.players[i] isonground();
			vel = level.players[i] getvelocity() * 0.05;

			check_dist = level.portalcheckdist;
			if (player_on_ground)
				check_dist *= 0.2;

			else if (vectordot(vel,p1.trace["normal"]) > 60)
				check_dist *= 1.5;

			if (!(distancesquared(p1.trace["position"], level.players[i].origin) < check_dist * check_dist))
				continue;

			if (vectordot(vel,p1.trace["normal"]) > 0 || vectordot(level.players[i].origin-p1.trace["position"] + (0, 0, 5),p1.trace["normal"]) <= 0)	//player isn't coming at portal
				continue;

			vec = level.players[i].origin + level.players[i] getcenter() - p1.trace["position"] + vel + c * (vel[2] < 0);
			offset = (vectordot(vec, p1.trace["right"]), vectordot(vec, p1.trace["up"]), vectordot(vec, p1.trace["normal"]));

			z = abs(p1.trace["normal"][2]);

			x_add = -16;
			y_add = 0;

			if (isInPortal(offset[0], offset[1], x_add,y_add) && offset[2] < (z * 40 + (1 - z) * 20))
				level.players[i] portalKick(p1, p2, vel);
		}
		wait 0.05;
	}
}

portalKick(p1, p2, vel)
{
	self endon("death");
	self endon("disconnect");

	self.portal["inportal"] = true;
	strength = length(vel);

	if (strength < 0)
	{
		wait 0.05;
		self.portal["inportal"] = false;
		return;
	}
	if (self.portal["first_enter"])
	{
		strength += 5;
		self thread watchAirTime();
	}

	strength = int(strength * 0.2) * 5;
	if ((strength < 15) && (p2.trace["normal"][2] >= 0))
		strength = 15 * (p2.trace["normal"][2]) + (p2.trace["normal"][2] == 0) * 1.5;
	else if (p2.trace["normal"][2] == -1)
		strength = 10;

	multiplier = 210;
	if (strength >= 40 && strength <= 50)
		multiplier = 192;
	else if (strength >= 55 && strength <= 70)
		multiplier = 180;
	else if (strength >= 70)
		multiplier = 160;

	if (strength >= 20)
		self playLocalSound("player_portal_enter");

	vec = self.origin - p1.trace["position"];
	offset = (vectordot(vec, p1.trace["right"]), vectordot(vec, p1.trace["up"]), 0);
	if (abs(offset[0]) > (level.portalwidth / 2 - 16))
		offset = ((level.portalwidth / 2 - 16) * sign(offset[0]), offset[1], 0);

	if (offset[1] < (level.portalheight / -2))
		offset = (offset[0], (level.portalheight / -2), 0);
	if (offset[1] > (level.portalheight / 2 - 72))
		offset = (offset[0], (level.portalheight / 2 - 72), 0);

	position = p2.trace["portal_out"] + p2.trace["right"] * offset[0] * -1 + p2.trace["up"] * offset[1];
	if (playerphysicstrace(position, position + p2.trace["normal"]) != position + p2.trace["normal"])
		position = p2.trace["safe_exit"];

	p1 playsound("portal_enter");
	self resetVelocity(position);

	if (!(getdvarint("portal_help_orientation") && p1.trace["on_ground"] && p2.trace["on_ground"]))	//disable rotations completely if dvar is true and both portals on ground
		self setplayerangles(playerPortalOutAngles(p1.trace["angles"], p2.trace["angles"], self getPlayerAngles()));

	earthquake(0.5, 0.2, self eyepos(), 100);

	self thread portalTurnZ();
	self thread launch("MOD_UNKNOWN", "portal", self.origin, p2.trace["normal"], strength * multiplier);

	wait 0.05;

	p2 playsound("portal_exit");

	if (p2.trace["normal"][2] >= 0)
		wait 0.45;
	else
		wait 0.1;

	self.portal["inportal"] = false;
}

resetVelocity(pos)
{
	self freezeControls(true);
	wait 0.05;

	if (!isDefined(self))
		return;

	self freezeControls(false);
	self setOrigin(pos);
}

watchAirTime()
{
	self endon("death");
	self endon("disconnect");

	self.portal["first_enter"] = false;

	while (!self isonground())
		wait 0.1;

	self.portal["first_enter"] = true;
}

portalTurnZ()
{
	self notify("portalTurnZ");
	self endon("portalTurnZ");

	self endon("death");
	self endon("disconnect");

	angles = self getPlayerAngles();
	if (!angles[2]) return;

	if (abs(angles[2]) == 180)
		if (RandomIntRange(0, 2))
			angles *= (1, 1, -1);

	sign = sign(angles[2]);

	startValue = 15;
	turnAmount = startValue;

	for (x = 0; abs(angles[2]) - turnAmount > 0; x++)
	{
		wait 0.05;
		angles = self getPlayerAngles() - (0, 0, turnAmount * sign);
		self setPlayerAngles(angles);
		turnAmount = StartValue * exp(0.95, x);
	}
	self setPlayerAngles(self getPlayerAngles() * (1, 1, 0));
}

aimDownSight()
{
	if (!self.portal["inzoom"])
		self thread portalZoomIn();
	else
		self thread portalZoomOut();
}

portalZoomIn()
{
	self allowads(true);
	self _exec("+toggleads_throw");
	self.portal["inzoom"] = true;
}

portalZoomOut()
{
	self allowads(false);
	self _exec("-toggleads_throw");
	self.portal["inzoom"] = false;
}

portalActivate()
{
	self notify("Deactivate_Portals");

	self thread portalWait("blue" ,"red");
	self thread portalWait("red" ,"blue");

	self.portal["blue"].active = true;
	self.portal["red"].active = true;
}

portalCleanArray(portal)
{
	newarray = [];
	for (i = 0; i < level.portals.size; i ++)
	{
		if (level.portals[i] == portal)
			continue;
		newarray[newarray.size] = level.portals[i];
	}
	level.portals = newarray;
}

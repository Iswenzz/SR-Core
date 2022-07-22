#include sr\libs\portal\_general;
#include sr\libs\portal\_hud;
#include sr\libs\portal\_portal;
#include sr\utils\_common;
#include sr\utils\_math;
#include sr\sys\_events;
#include sr\sys\_dvar;

main()
{
	level.portal_objects = [];
	level.portal_width = 70;
	level.portal_height = 110;
	level.portal_options_num = 2000;
	level.portal_check_dist = 700;
	level.portal_surfaces = strTok("concrete,carpet,brick,asphalt,glass,plaster,plastic,gravel,ice,wood,grass,mud,dirt,metal,paper,rock,sand,snow,wood,paintedmetal", ",");

	level.portalgun_w = "w_portalgun";
	level.portalgun_v = "v_portalgun";
	level.portalgun = "portalgun_mp";
	level.portalgun_bendi = "portalgun_bendi_mp";
}

watch()
{
	self endon("disconnect");
	self endon("death");

	if (!isDefined(self.portals))
		self.portals = [];

	self resetPortals();

	while (true)
	{
		wait 0.05;

		if (self getCurrentWeapon() != level.portalgun || self isOnLadder() || self isMantling() || self.throwingGrenade)
		{
			self sr\libs\portal\_hud::updateHud("none");
			wait 1;
			continue;
		}

		color = undefined;
		if (self attackButtonPressed())
			color = "blue";
		else if (self aimButtonPressed())
			color = "red";
		else if (self fragButtonPressed())
			self resetPortals();

		if (isDefined(color))
		{
			self playLocalSound("portal_gun_shoot_" + color);
			self thread portal(color);
		}
		while (self attackButtonPressed() || self aimButtonPressed() || self fragButtonPressed())
			wait 0.05;
	}
}

resetPortals()
{
	self notify("Deactivate_Portals");

	self thread portalDelete("blue");
	self thread portalDelete("red");

	if (self.sr_mode == "Portal")
		self thread updatehud("default");
}

stopAll(delete_portals, disconnected)
{
	if (delete_portals)
	{
		self notify("Deactivate_Portals");

		self thread portalDelete("blue");
		self thread portalDelete("red");

		self notify("place_turret");
		if (isDefined(self.test_turret))
			self.test_turret delete();

		for (i = 0; i < self.turrets.size; i++)
			self.turrets[i] sr\libs\portal\_turret::turretDelete();

		self.turrets = [];
	}

	self notify("stop_watch_button");
	self notify("stop_watch_fps");

	if (isDefined(disconnected))
		return;

	if (self hasweapon(level.portalgun) && !delete_portals)
		self setweaponammoclip(level.portalgun, 0);

	self allowads(true);
	self.portal["inzoom"] = false;
	self.portal["can_use"] = false;

	self thread updatehud("none");
	self notify("stopAll");
}

portal(color)
{
	othercolor = othercolor(color);

	eye = self eyepos();
	forward = anglesToForward(self getPlayerAngles()) * level.maxdistance;
	trace = traceArray(eye, eye + forward, false, level.portal_objects);

	if (trace["fraction"] == 1)
		portalfailed = true;
	else
		portalfailed = false;

	if (!portalfailed)
	{
		portalfailed = true;
		for (i = 0; i < level.portal_surfaces.size; i++)
		{
			if (trace["surfacetype"] == level.portal_surfaces[i])
				portalfailed = false;
		}
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

	if (on_ground)
		angles = (angles[0], self getPlayerAngles()[1] - 180, 0);

	right =	anglestoright(angles);
	up = anglestoup(angles);

	if (!portalfailed)
	{
		slope_increase = abs(normal[2]) * 3 * !on_ground;

		width = level.portal_width;
		height = level.portal_height + slope_increase;

		if (on_ground)
			width = height * 0.8;

		forward = normal * (1 + terrain * 5 * on_ground);
		backward = forward * -1;

		portals = [];

		for (i = 0; i < self.portals.size; i++)
		{
			if (isDefined(self.portal[color]))
				if (self.portal[color] == self.portals[i])
					continue;

			p = self.portals[i].trace["position"];
			q = pos;

			vec = pos - self.portals[i].trace["position"];

			a = self.portals[i].trace["right"];
			b = self.portals[i].trace["up"];
			c = self.portals[i].trace["normal"];

			trans = (vectordot(vec, a), vectordot(vec, b), vectordot(vec, c));

			if (!(round(trans[2], -1)))
			{
				x = abs(trans[0]);
				y = abs(trans[1]);
				if (x < 2 * width && y < 2 * height)
					portals[portals.size] = self.portals[i];

				if (x < width && y < height)
				{
					if (y < x * (height / width))
						pos = p + b * trans[1] + a * width * sign(trans[0]);
					else
						pos = p + a * trans[0] + b * height * sign(trans[1]);

					if (traceArray(p + forward, pos + forward, false, level.portal_objects)["fraction"] != 1)
					{
						portalfailed = true;
						break;
					}
				}
			}

		}

		vec = [];
		vec[1] = up * (1 + (height / 2));
		vec[2] = vec[1] * -1;
		vec[3] = right * (1 + (width / 2)) * -1;
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
			hit = 1 - traceArray(pos + forward, pos + forward + vec[i], false, level.portal_objects)["fraction"];

			if (!hit)
			{
				tmp_ground_trace = traceArray(pos + forward + vec[i], pos + backward + vec[i], false, level.portal_objects);
				if (tmp_ground_trace["fraction"] == 1)
					hit = traceArray(pos + backward + vec[i], pos + backward, false, level.portal_objects)["fraction"];
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
			playfx(level.fx[color + "portal_fail"], trace["position"] + trace["normal"]);
		}
	}
}

portalDelete(color)
{
	if (!self.portal[color + "_exist"])
		return;

	level notify("portal_rearange");

	self.portal[color] stoploopSound();
	self.portal[color] playSound("portal_close");
	self.portal[color] playSound("portal_close_" + color);
	self.portal[color] notify("stop_fx");

	playfx(level.fx[color + "portal_close"], self.portal[color].trace["position"], self.portal[color].trace["normal"], self.portal[color].trace["up"]);

	if (isDefined(self.portal[color].bullet))
		self.portal[color].bullet delete();
	self.portal[color].dummy delete();
	self.portal[color] delete();
	self.portal[color + "_exist"] = false;

	portalCleanArray(self.portal[color]);
}

portalCreate(color, trace)
{
	self.portal["inportal"] = false;

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
	self.portals[self.portals.size] = self.portal[color];
	self.portal[color + "_exist"] = true;

	if (self.portal["blue_exist"] && self.portal["red_exist"])
		self thread portalActivate();

	portal[color] portalFX();
}

portalFX()
{
	self endon("stop_fx");

	oldpos = self.trace["old_position"];
	fxpos = self.trace["fx_position"];
	p = self.trace["start_position"];
	p += vectornormalize(oldpos - p) * 33;
	speed = 50000;

	t = length(fxpos - p) / speed * 1.5;
	if (t > 0.5)
		t = 0.5;

	self.bullet = spawn("script_model" , (-10000, 0, 0));
	self.bullet setmodel("collision_sphere");
	self.bullet hide();
	self.bullet showToPlayer(self.owner);

	wait 0.05;

	playfxontag(level.fx["portalball" + self.color], self.bullet, "collision_sphere");

	angles = self.owner getplayerangles();

	f = anglestoforward(angles);
	u = anglestoup(angles);
	r = vectorprod(f,u);

	self.bullet moveCurve(self.owner eyepos() + f * 22 + u * -6 + r, oldpos, self.trace["position"], t);

	self thread playOpenSound(self.color, fxpos + self.trace["normal"] * 2);

	self setmodel("portal_" + self.color);
	self hide();
	self showToPlayer(self.owner);

	self.dummy setmodel("portal_dummy_" + self.color);
	self.dummy hide();
	self.dummy showToPlayer(self.owner);

	playfx(level.fx[self.color + "portal_open"], fxpos, self.trace["normal"], self.trace["up"]);
	wait 0.75;

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
	if (isDefined(self))
		self moveto((0, 0, 100000), 0.05);

	wait 0.1;
	if (isDefined(self))
		self delete();
}

portalWait(color, othercolor)
{
	self endon("Deactivate_Portals");
	self endon("disconnect");
	self endon("death");

	p1 = self.portal[color];
	p2 = self.portal[othercolor];

	self.portal[color].otherportal = self.portal[othercolor];

	c = ((0, 0, sr\api\_map::getGravity(800)) + (0, 0, 15)) * -0.05;

	while (true)
	{
		wait 0.05;

		if (self.portal["inportal"])
			continue;

		player_on_ground = self isonground();
		vel = self getvelocity() * 0.05;

		check_dist = level.portal_check_dist;
		if (player_on_ground)
			check_dist *= 0.2;
		else if (vectordot(vel, p1.trace["normal"]) > 60)
			check_dist *= 1.5;

		if (!(distancesquared(p1.trace["position"], self.origin) < check_dist * check_dist))
			continue;

		// Player isn't coming at portal
		if (vectordot(vel, p1.trace["normal"]) > 0 || vectordot(self.origin-p1.trace["position"] + (0, 0, 5),
			p1.trace["normal"]) <= 0)
			continue;

		vec = self.origin + self getcenter() - p1.trace["position"] + vel + c * (vel[2] < 0);
		offset = (vectordot(vec, p1.trace["right"]), vectordot(vec, p1.trace["up"]), vectordot(vec, p1.trace["normal"]));

		z = abs(p1.trace["normal"][2]);

		x_add = -16;
		y_add = 0;

		if (isInPortal(offset[0], offset[1], x_add,y_add) && offset[2] < (z * 40 + (1 - z) * 20))
			self portalKick(p1, p2, vel);
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
	if (abs(offset[0]) > (level.portal_width / 2 - 16))
		offset = ((level.portal_width / 2 - 16) * sign(offset[0]), offset[1], 0);

	if (offset[1] < (level.portal_height / -2))
		offset = (offset[0], (level.portal_height / -2), 0);
	if (offset[1] > (level.portal_height / 2 - 72))
		offset = (offset[0], (level.portal_height / 2 - 72), 0);

	position = p2.trace["portal_out"] + p2.trace["right"] * offset[0] * -1 + p2.trace["up"] * offset[1];
	if (playerphysicstrace(position, position + p2.trace["normal"]) != position + p2.trace["normal"])
		position = p2.trace["safe_exit"];

	p1 playsound("portal_enter");
	self setOrigin(position);

	if (!(getdvarint("portal_help_orientation") && p1.trace["on_ground"] && p2.trace["on_ground"]))	//disable rotations completely if dvar is true and both portals on ground
		self setplayerangles(playerPortalOutAngles(p1.trace["angles"], p2.trace["angles"], self getPlayerAngles()));

	earthquake(0.5, 0.2, self eyepos(), 100);

	self thread launch(self.origin, p2.trace["normal"], strength * multiplier);

	wait 0.05;

	p2 playsound("portal_exit");

	if (p2.trace["normal"][2] >= 0)
		wait 0.45;
	else
		wait 0.1;

	self.portal["inportal"] = false;
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
	self clientCmd("+toggleads_throw");
	self.portal["inzoom"] = true;
}

portalZoomOut()
{
	self allowads(false);
	self clientCmd("-toggleads_throw");
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
	for (i = 0; i < self.portals.size; i ++)
	{
		if (self.portals[i] == portal)
			continue;
		newarray[newarray.size] = self.portals[i];
	}
	self.portals = newarray;
}

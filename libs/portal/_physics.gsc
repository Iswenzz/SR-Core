#include sr\libs\portal\_general;
#include sr\utils\_math;

physicsStop()
{
	self notify("physics_stop");
	self.origin = self.origin;
	self.angles = self.angles;
}

// Check if there is a portal object in the way
portalObjectCollisionTrace(start, end)
{
	trace["hit"] = false;
	if (!trace["hit"])
	{
		ignore_ents = self portalAddIgnoreEnts();
		trace = traceArray(start, end, false, ignore_ents);
		trace["hit"] = (trace["fraction"] != 1);
	}
	else
		iprintln("hit pobject");
	return trace;

}

portalAddIgnoreEnts()
{
	ignore_ents = [];
	ignore_ents[0] = self;

	if (isDefined(self.physics["model_parts"]))
	{
		for (i = 0; i < self.physics["model_parts"].size; i++)
			ignore_ents[i + 1] = self.physics["model_parts"][i];
	}
	for (i = 0; i < level.portalobjects.size; i++)
		ignore_ents[ignore_ents.size] = level.portalobjects[i];

	return ignore_ents;
}

physicsStart(initial_vel)
{
	self notify("physics_start");
	self endon("physics_start");
	self endon("physics_stop");

	obj_bounce = self.physics["bounce"];
	obj_adhesion = self.physics["adhesion"];
	obj_rotate = self.physics["rotate"];
	obj_rotation_speed = self.physics["rotation_speed"];
	colSize = self.physics["colSize"];

	rotation = 4;			// Rotation duration
	max = 10;				// Max duration
	strengthmin = 10; 		// Decides when the object should stop bouncing on floor
	increase = (0, 0, -2);	// Constant increase in speed due to gravity

	trace["position"] = (0, 0, 0);
	trace["normal"] = (0, 0, -1);

	vel = initial_vel / 20;
	strength = length(vel);

	while (strength > strengthmin * (1 - obj_bounce) || trace["normal"][2] <= (1 - obj_adhesion))
	{
		self movegravity(vel * 20, max);

		while (true)
		{
			vel += increase;
			pos1 = self.origin;
			pos2 = pos1 + vel;

			if (self.physics["colType"] == "cube")
				add = vectornormalize(vel) * colSize + ((0, 0, -1) * colSize / 2) * (sign2(vel[2]) != 1);
			else
				add = vectornormalize(vel) * colSize;

			trace = self portalobjectCollisionTrace(pos1, pos2 + add);
			if (trace["hit"])
				break;
		}
		surfaceBounce = surfaceBounce(trace["surfacetype"]);

		// Reflection vector projected at wallnormal
		vel1 = vectordot(trace["normal"], vel) * trace["normal"] * -1;
		// Reflection vector projected at wall (needed later for rotation)
		vel2 = vel + vel1;
		// Calculate the reflection vector
		vel = vel1 + vel2;
		// Calculate lost force
		vel = (vel + increase*2)*(1 - (1-obj_bounce)*(1-surfaceBounce));
		strength = length(vel);

		if (isDefined(self.physics["bounce_sound"]))
			self playsound(self.physics["bounce_sound"]);
	}
	self.angles = anglesNormalize(self.angles);

	// note: very poorly scripted, cod4s rotations are just too hard to understand
	if (self.physics["colType"] == "cube")
	{
		alpha = 0;
		beta = 0;
		if (round(trace["normal"][2],1) != 1)
		{
			// Try to find the face that is the closest to ground
			v[0] = anglestoforward(self.angles);
			v[1] = anglestoright(self.angles) * -1;
			v[2] = vectorprod(v[0], v[1]);

			inverted = [];
			distances = [];
			for (i = 0; i < 3; i++)
			{
				inverted[i] = 1;
				distances[i] = distancesquared(v[i], trace["normal"]*-1);

				// Degree between wallnormal and vector > 90
				if (distances[i] > 2)
				{
					inverted[i] = -1;
					distances[i] = distancesquared(v[i], trace["normal"]);
				}
			}

			x = vectorSmallestValueIndex(distances);	// Index of the face-normal that is pointing to ground
			if (!(x == 2 && inverted[2] == -1))		// Z isnt up, fk it, too complicated (could add every case)
			{
				/*
				self.angles = (self.angles[0],self.angles[1],0);

				// Tried rotating the cube so that z will be up since it works then
				x = vectorSmallestValueIndex(distances);
				iprintln(x);
				drawline(trace["position"] + (0, 0, 20), trace["position"] + (0, 0, 20) + v[x] * inverted[x] * 50);

				self.origin = trace["position"] + (0, 0, 20);
				iprintln("rotating z up");

				wait 5;

				rotate = (90 * (x == 0) * inverted[0] * -1 + 180 * (x == 2) * (inverted[2] == 1),
					0, 90 * (x == 1) * inverted[1]);

				self.angles += rotate;
				*/
			}
			else
			{
				// Degree between wallnormal and vector > 90
				x = -1;
				if (distancesquared(v[0], trace["normal"] * -1) > 2)
					x = 1;

				alpha = acos(vectordot(vectornormalize(vectorprod(v[1], trace["normal"])), v[0])) * x;
				beta = acos(vectordot(vectornormalize(vectorprod(v[0], trace["normal"])), v[2]));
			}
		}
		snap_angles = (angleSnap90(self.angles[0], alpha), self.angles[1], angleSnap90(self.angles[2], beta));
		new_angles = snap_angles;
	}
	else
		new_angles = self.angles;

	self.origin = trace["position"]+(0,0,self.physics["colSize"]);

	self rotateto(new_angles, 0.05);
	self notify("physics_stop");
}

startGrenadePhysics(initial_vel, is_c4)
{
	self notify("physics_start");
	self endon("physics_start");
	self endon("physics_stop");
	self endon("remove");

	obj_bounce = 0.2;
	obj_adhesion = 0.1;
	strengthmin = 10;
	increase = (0,0,-2);

	trace["position"] = (0,0,0);
	trace["normal"] = (0,0,-1);

	vel = initial_vel / 20;
	strength = 100;
	max = 10;
	bounce_count = 0;
	maxloops = 5;
	infinite_loop_stop = maxloops;

	while ((strength > strengthmin * (1 - obj_bounce) || trace["normal"][2] < (1 - obj_adhesion)) && infinite_loop_stop >= 0)
	{
		self movegravity(vel * 20, max);

		wait 0.05;

		vel += increase / 2;

		while (true)
		{
			waittillframeend;
			pos1 = self.origin;
			pos2 = pos1 + vel;

			ignore_ent[0] = self;
			if (isDefined(self.originalgrenade))
				ignore_ent[1] = self.originalgrenade;
			trace = self traceArray(pos1, pos2, false, ignore_ent);

			if (trace["fraction"] != 1)
				break;

			infinite_loop_stop = maxloops;
			vel += increase;

			wait 0.05;
		}
		bounce_count++;

		if (is_c4)
			break;

		vel1 = vectordot(trace["normal"], vel) * trace["normal"] * -1;
		vel2 = vel + vel1;
		vel = vel1 * 0.25 + vel2 * 0.5;
		strength = length(vel);
		self playsound("grenade_bounce_" + trace["surfacetype"]);

		infinite_loop_stop--;
	}

	self.origin = trace["position"] + (0, 0, 2);
	if (isDefined(self.originalGrenade))
		self.originalGrenade show();
	self.angles = self.angles;

	self delete();
	self notify("physics_stop");
}

surfaceBounce(surfacetype)
{
	switch (surfacetype)
	{
		default: return 0.5;
	}
}

// Trace from player while he is holding an object using the given collision size
playerPortalObjectCollisionTrace(start, angles, distance)
{
	ignore_ents = self portalAddIgnoreEnts();

	colSize = self.physics["colSize"];
	object_radius = self.physics["colSize_forward"];

	r = 16;	// player radius
	h = 15;	// height above start: player height

	forward = anglestoforward(angles);
	pos = start + forward*(r + distance + colSize);
	object_radius = self givecollisionradius(forward);
	end = pos + forward*object_radius;
	updatedpos = pos;
	playerheight = 25;

	for (i = 0; i < level.players.size; i++)
	{
		vec = level.players[i].origin+(0,0,playerheight)-pos;
		obj_r = self givemaxcollisionradius();
		if (lengthsquared((vec[0], vec[1], 0)) < exp(r + obj_r, 2) && abs(vec[2] - obj_r) < playerheight)
		{
			obj_r = self givecollisionradius(vec);
			if (lengthsquared((vec[0], vec[1], 0)) < exp(r + obj_r, 2) && abs(vec[2] - obj_r) < playerheight)
				iprintln("hit player");
		}
	}

	trace = traceArray(start, end, false, ignore_ents, ignore_ents[0]);
	in_portal = false;
	angles2 = (0, angles[1], 0);

	if (!in_portal)
	{
		if (trace["fraction"] == 1)
		{
			// Do a trace to the left
			left = vectorprod((0, 0, 1), forward);
			trace = traceArray(pos, pos + left * object_radius, false, ignore_ents, ignore_ents[1]);
			if (trace["fraction"] == 1)
			{
				// Do a trace to the right
				trace = traceArray(pos, pos - left * object_radius, false, ignore_ents, ignore_ents[2]);
				if (trace["fraction"] == 1)
				{
					// No walls interfering, check for other objects
					trace = self portalObjectCollisionTraceOnly(pos);
					if (trace["hit"])
						return pos;
					else
						return pos;
				}
			}
		}

		q = trace["position"];
		u = trace["normal"];
		a = vectordot(u, (start - q)) - object_radius;
		wall_angles = vectortoangles(u * -1);
		dir = sign(angleNormalize(angles[1] - wall_angles[1]));

		v = vectorprod((0, 0, 1), u);
		w = vectorprod(u, v);
		c = vectordot((q-start), w);
		b = abs(vectordot(q - start, v));

		touchingplayer = (a <= (r + object_radius) && b <= (r + object_radius) && c < h + object_radius);
		if (touchingplayer)
			b = sqrt((r + object_radius) * (r + object_radius) - a * a);

		updatedpos = start - u * a - b * v * dir + w * c;
		t = traceArray(updatedpos + u, updatedpos - v * dir * object_radius + u, false, ignore_ents, ignore_ents[1]);

		// Check if another wall is interfering at updatedpos
		if (t["fraction"] != 1)
		{
			if (touchingplayer)
				updatedpos = start - u * a + b * v * dir + w * c ;
			else
				updatedpos = t["position"] + v * dir * object_radius - u;
		}
	}
	return updatedpos;
}

// Check if there is a portal object at pos
portalObjectCollisionTraceOnly(pos)
{
	trace["hit"] = false;
	trace["position"] = pos;
	trace["hit_object"] = undefined;
	trace["normal"] = undefined;

	for (i = 0; i < level.portalobjects.size; i++)
	{
		if (self == level.portalobjects[i])
			continue;
		if (isDefined(self.physics["ignore_ents"]))
			if (level.portalobjects isInArray(self.physics["ignore_ents"]))
				continue;

		if (exp(self givemaxcollisionradius() + level.portalobjects[i] givemaxcollisionradius(), 2) > distancesquared(pos, level.portalobjects[i].origin))	//cheap guess if objects might collide
		{
			vec = pos - level.portalobjects[i].origin;
			r1 = level.portalobjects[i] givecollisionradius(vec);
			r2 = self givecollisionradius(vec*-1);

			if (exp(r1 + r2, 2) > distancesquared(pos, level.portalobjects[i].origin))	//objects collide
			{
				trace["hit"] = true;
				trace["hit_object"] = level.portalobjects[i];
				trace["normal"] = vectornormalize(vec);
				if (trace["normal"] == (0,0,0))
					trace["normal"] = (0,0,1);

				trace["fraction"] = 1 - level.portalobjects[i] givecollisionradius(vec) / length(vec);
				trace["position"] = level.portalobjects[i].origin + vec*trace["fraction"];
				trace["surfacetype"] = "portal_object";
				break;
			}
		}
	}
	return trace;
}

giveMaxCollisionRadius()
{
	if (self.physics["colType"] == "sphere")
		return self.physics["colSize"];
	if (self.physics["colType"] == "cube")
		return self.physics["colSize"] * 1.73;
	if (self.physics["colType"] == "cylinder")
		return self.physics["colHeight"] * 1.2;
	return 0;
}

giveCollisionRadius(direction)
{
	array = [];
	if (direction == (0, 0, 0))
	{
		array["radius"] = self givemaxcollisionradius();
		return array;
	}
	if (self.physics["colType"] == "sphere")
		return self.physics["colSize"];
	if (self.physics["colType"] == "cube")
	{
		a = anglestoforward(self.angles);
		b = anglestoright(self.angles) * -1;
		c = vectorprod(a, b);

		vec_dir = (vectordot(direction, a), vectordot(direction, b), vectordot(direction, c));
		angles = anglesNormalize(vectortoangles(vec_dir));

		M = [];
		M[0] = [];
		M[1] = [];
		M[2] = [];

		M[0][0] = a[0];
		M[0][1] = a[1];
		M[0][2] = a[2];
		M[1][0] = b[0];
		M[1][1] = b[1];
		M[1][2] = b[2];
		M[2][0] = c[0];
		M[2][1] = c[1];
		M[2][2] = c[2];

		alpha = angleMax45(angles[1]);
		beta = angleMax45(angles[0]);
		array["radius"] = (self.physics["colSize"] / cos(alpha)) / cos(beta);
	}
	if (self.physics["colType"] == "cylinder")
		return self.physics["colHeight"] * 1.2;
	return array["radius"];
}

biggestValue(vec)
{
	return (sign(vec[0]) * (vec[0] >= vec[1] && vec[0] >= vec[2]),
		sign(vec[1]) * (vec[1] > vec[0] && vec[1] >= vec[2]),
		sign(vec[2]) * (vec[2] > vec[1] && vec[2] > vec[0]));
}

angleMax45(angle)
{
	while (abs(angle) > 45)
		angle = sign(angle) * 90 - angle;
	return angle;
}

mirrorObject(portal1, portal2, trans, angles)
{
	self notify("stop_mirror");
	self endon("stop_mirror");

	pos = portal2.origin + portal2.trace["right"] * trans[0] * -1
		+ portal2.trace["up"] * trans[1] + portal2.trace["normal"] * trans[2] * -1;

	if (!isDefined(self.physics["mirrorobject"]))
	{
		self.physics["mirrorobject"] = spawn("script_model", pos);
		self.physics["mirrorobject"] setmodel(self.physics["name"]);
	}

	self.physics["mirrorobject"].origin = pos;
	self.physics["mirrorobject"].angles = portalOutAngles(portal2.angles, portal1.angles, angles);
	self.physics["mirrorobject"].portal1id = portal1.id;
	self.physics["mirrorobject"].portal2id = portal2.id;
	self.physics["mirrorobject"].delete = false;

	while (true)
	{
		self waittill("update_mirror_pos", trans, angles);

		self.physics["mirrorobject"] moveto(portal2.origin + portal2.trace["right"] * trans[0] * -1
			+ portal2.trace["up"] * trans[1] + portal2.trace["normal"] * trans[2] * -1, 0.1);
		self.physics["mirrorobject"] rotateto(portalOutAngles(portal2.angles, portal1.angles, angles), 0.1);
	}
}

mirrorDelete()
{
	self.physics["mirrorobject"].delete = true;
	wait 0.1;
	self notify("stop_mirror");
	self.physics["mirrorobject"] delete();
	self.physics["mirrorobject"] = undefined;
}

boxCollisionTrace(pos, angles, colSize, ignore_ent)
{
	pos += (0, 0, colSize);

	forward = anglestoforward(angles);
	right = anglestoright(angles);
	up = vectorprod(right, forward);

	vec = [];
	vec[0] = forward * (1 + colSize);
	vec[1] = vec[0] * -1;
	vec[2] = right * (1 + colSize);
	vec[3] = vec[2] * -1;
	vec[4] = up * (1 + colSize);
	vec[5] = vec[4] * -1;

	fail = [];
	for (i = 0; i < 6; i++)
	{
		hit = 1 - bulletTrace(pos , pos + vec[i], false, ignore_ent)["fraction"];

		if (hit)
		{
			fail[fail.size] = i;
			fail[fail.size] = hit;
			i++;
		}
	}
	for (i = 0; i < fail.size; i += 2)
		pos -= vec[fail[i]] * fail[i+1];

	return pos;
}

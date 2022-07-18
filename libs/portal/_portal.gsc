#include sr\utils\_math;
#include sr\libs\portal\_hud;

isInPortal(x, y, rx_add, ry_add)
{
	if (!isDefined(rx_add))
		rx_add = 0;
	if (!isDefined(ry_add))
		ry_add = 0;
	rx = (level.portal_width/2) + rx_add;
	ry = (level.portal_height/2) + ry_add;
	return ((x * x) / (rx * rx) + y * y / (ry * ry)) <= 1;
}

isPortalGun(weapon)
{
	return issubstr(weapon, level.portalgun);
}

launch(origin, direction, strength)
{
	self endon("death");
	self endon("disconnect");

	dir = [];
	dir[0] = abs(direction[0]);
	dir[1] = abs(direction[1]);
	dir[2] = abs(direction[2]);

	max = GetMax(dir);
	directionIndex = IndexOf(dir, max);
	sign = Ternary(direction[directionIndex] > 0, 1, -1);

	velocity = strength / 9;
	switch (directionIndex)
	{
		case 0: direction = (velocity, 0, 0); break;
		case 1: direction = (0, velocity, 0); break;
		case 2: direction = (0, 0, velocity); break;
	}
	direction *= sign;

	self setVelocity(direction);
}

_linkto(ent)
{
	self thread _linkto_thread(ent);
}

_linkto_thread(ent)
{
	self notify("unlink");
	self endon("unlink");
	self endon("death");
	ent endon("death");

	while (true)
	{
		if (!isDefined(ent) || !isDefined(self))
			self notify("unlink");
		self.origin = ent.origin;
		wait 0.05;
	}
}

portalSpawn(
	name,		// String of the modelname
	pos, 		// Positionvector
	angles, 	// Anglevector
	colType, 	// Type of collision used, String "cube", "sphere", "cylinder"
	colSize, 	// Size of the collision Box
	bounce, 	// Bounce factor (force absorption by collision with wall), floatvalue 0-1
	adhesion, 	// Object adhesion (min wall-slope the object will stick to, values are 1 - wallnormal[2]; the higher, the stickier), floatvalue 0-1
	rotate, 	// Object rotates, boolean (true/false)
	rot_speed, 	// Object rotation speed, floatvalue 0-1
	cyl_height	// Height of the Collisioncylinder
)
{
	model = spawn("script_model", pos);
	model setmodel(name);
	model.angles = angles;
	model.physics = [];
	model.physics["name"] = name;
	model.physics["colType"] = colType;
	model.physics["colSize"] = colSize;
	model.physics["colHeight"] = cyl_height;
	model.physics["bounce"] = bounce;
	model.physics["adhesion"] = adhesion;
	model.physics["rotate"] = rotate;
	model.physics["rotation_speed"] = rot_speed;
	model.physics["sway_amount"] = 5;
	model.physics["sway_speed"] = 0.5;
	model.physics["model_parts"] = [];

	level.portal_objects[level.portal_objects.size] = model;

	return model;
}

setTriggerUse()
{
	self endon("setTriggerNormal");
	self endon("delete");

	while (true)
	{
		self waittill("trigger", player);
		if (player usebuttonpressed())
		{
			self notify("trigger_activate", player);
			wait 0.1;
		}
	}
}

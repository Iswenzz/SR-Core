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

launch(sMeansOfDeath, sWeapon, vPoint, vDir, strength)
{
	self endon("death");
	self endon("disconnect");

	maxhealth = self.maxhealth;
	health = self.health;

	self.maxhealth += 1000000;
	self.health += 1000000;

	setDvar("g_knockback", strength);
	self FinishPlayerDamage(self, self, 100, 0, sMeansOfDeath, sWeapon, vPoint, vDir, "none", 0);

	wait 0.05;

	setDvar("g_knockback", level.defaultknockback);

	self.maxhealth 	= maxhealth;
	self.health 	= health;
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

portalGunSpawn(pos, angles)
{
	portalgun = spawn("script_model", pos);
	portalgun setmodel(level.portalgun_w);

	if (isDefined(angles))
		portalgun.angles = angles;

	portalgun.trigger = spawn("trigger_radius", pos, 0, 50, 40);

	portalgun thread waitForPickup();
	portalgun.trigger thread setTriggerUse();

	return portalgun;
}

waitForPickup()
{
	self.trigger waittill("trigger_activate", player);
	self notify("delete");
	self.trigger delete();
	self delete();
	player dropitem(player getcurrentweapon());
	player giveweapon(level.portalgun);
	player switchtoweapon(level.portalgun);

	level.hiddenportalgun = undefined;
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

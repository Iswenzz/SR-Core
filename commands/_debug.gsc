#include sr\sys\_admins;
#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
	cmd("owner",  		"debug_ents",		::cmd_DebugEnts);
	cmd("owner",  		"debug_speed",		::cmd_DebugSpeed);
	cmd("owner",  		"debug_surface",	::cmd_DebugSurface);
	cmd("owner",  		"test",				::cmd_Test);
}

cmd_DebugSurface(args)
{
	start = self getEye();
	end = start + vectorScale(anglesToForward(self getPlayerAngles()), 999999);
	trace = bulletTrace(start, end, true, self);

	if (isDefined(trace))
		self pm(fmt("Surface: ^5%s", trace["surfacetype"]));
}

cmd_DebugEnts(args)
{
	models = getEntArray("script_model", "classname").size;
	origins = getEntArray("script_origin", "classname").size;
	brushes = getEntArray("script_brushmodel", "classname").size;

	triggers = getEntArray("trigger_radius", "classname").size
		+  getEntArray("trigger_damage", "classname").size
		+  getEntArray("trigger_disk", "classname").size
		+  getEntArray("trigger_hurt", "classname").size
		+  getEntArray("trigger_multiple", "classname").size
		+  getEntArray("trigger_once", "classname").size
		+  getEntArray("trigger_use", "classname").size
		+  getEntArray("trigger_use_touch", "classname").size;

	self pm(fmt("^3Models: ^7%d", models));
	self pm(fmt("^5Origins: ^7%d", origins));
	self pm(fmt("^2Brushes: ^7%d", brushes));
	self pm(fmt("^1Triggers: ^7%d", triggers));
}

cmd_DebugSpeed(args)
{
	self pm(fmt("^5Speed: ^7%d %f %d %d", self.speed, self.moveSpeedScale, self.gravity, self.jumpHeight));
}

cmd_Test(args)
{
	rotation = sr\game\_map::getRotation(true);
	index = IndexOf(rotation, level.map);
	map = rotation[index + 1];

	if (isDefined(map))
		setDvar("sv_maprotationcurrent", "gametype deathrun map " + rotation[index + 1]);
	else
		exit(0);

	exitLevel(false);
}

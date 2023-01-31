#include sr\sys\_admins;
#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
	cmd("owner",  		"bots",					::cmd_Bots);
	cmd("owner",  		"debug_ents",			::cmd_DebugEnts);
	cmd("owner",  		"debug_ents_spawn",		::cmd_DebugEntsSpawn);
	cmd("owner",  		"debug_speed",			::cmd_DebugSpeed);
	cmd("owner",  		"debug_surface",		::cmd_DebugSurface);
	cmd("owner",  		"debug_save_spawn",		::cmd_DebugSaveSpawn);
	cmd("owner",  		"debug_scriptusage",	::cmd_DebugScriptUsage);
	cmd("owner",  		"debug_rotation",		::cmd_DebugRotation);
	cmd("owner",  		"debug_critical",		::cmd_DebugCriticalSections);
	cmd("owner",		"test",					::cmd_Test);

	if (getDvarInt("debug_rotation"))
		event("map", ::cmd_DebugRotation);
	if (getDvarInt("debug_save_spawn"))
		event("map", ::cmd_DebugSaveSpawn);
}

cmd_Bots(args)
{
	if (args.size < 1)
		return self pm("Usage: bots <amount>");

	amount = ToInt(args[0]);

	sr\utils\_common::spawnBots(amount);
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

cmd_DebugRotation(args)
{
	// Setup next map
	rotation = sr\game\_map::getRotation(true);
	index = IndexOf(rotation, level.map);
	map = rotation[index + 1];
	setDvar("sv_maprotationcurrent", "gametype deathrun map " + IfUndef(map, ""));

	// Next map
	if (isDefined(map))
		sr\game\_map::levelExit(false);
	else
		exit(0);
}

cmd_DebugSaveSpawn(args)
{
	// Setup next map
	rotation = sr\game\_map::getRotation(true);
	index = IndexOf(rotation, level.map);
	map = rotation[index + 1];
	setDvar("sv_maprotationcurrent", "gametype deathrun map " + IfUndef(map, ""));

	// Write map spawn
	wait 1;
	origin = level.spawn["player"].origin;
	angle = int(level.spawn["player"].angles[1]);
	file = FILE_Open(sr\sys\_file::PATH_Mod("spawns.txt"), "a+");
	FILE_WriteLine(file, fmt("case %s\nthread sr\\api\\_map::createSpawn((%.3f, %.3f, %.3f), %d);\nbreak;",
		level.map, origin[0], origin[1], origin[2], angle));
	FILE_Close(file);

	// Next map
	if (isDefined(map))
		sr\game\_map::levelExit(false);
	else
		exit(0);
}

cmd_DebugEntsSpawn(args)
{
	if (args.size < 1)
		return self pm("Usage: debug_ents_amount <amount>");

	ents = getEntArray("debug_ent", "targetname");
	for (i = 0; i < ents.size; i++)
		ents[i] delete();

	amount = ToInt(args[0]);

	for (i = 0; i < amount; i++)
	{
		ent = spawn("script_model", self.origin);
		ent.targetname = "debug_ent";
		ent setModel("chicken");
	}
	self pm(fmt("Spawned %d chicken", amount));
}

cmd_DebugCriticalSections(args)
{
	sections = CriticalSections();
	self pm(fmt("Critical sections: ^5%d", sections.size));
}

cmd_DebugScriptUsage(args)
{
	self pm(fmt("Script usage: ^5%d", debug_scriptusage()));
}

cmd_Test(args)
{
	// self command("bots", "1");
	// self command("killzone");
	// self command("cmd", "1 killzone");

	origin = spawn("script_model", self.origin);
	origin setContents(0);
	origin setModel("tag_origin");
	wait 0.2;
	origin playLoopSound("weap_quake_rocket_loop");
}

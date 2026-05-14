#include sr\sys\_admins;
#include sr\sys\_events;
#include sr\sys\_file;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
	cmd("bots",               "owner",       ::cmd_Bots,                 "Spawn bots");
	cmd("debug_critical",     "owner",       ::cmd_DebugCriticalSections,"Display critical sections");
	cmd("debug_ents_spawn",   "owner",       ::cmd_DebugEntsSpawn,       "Spawn an amount of entities");
	cmd("debug_ents",         "owner",       ::cmd_DebugEnts,            "Display all entities");
	cmd("debug_kz",           "owner",       ::cmd_DebugKZ,              "Spawn a bot inside the killzone");
	cmd("debug_origin",       "masteradmin", ::cmd_DebugOrigin,          "Add current position to the origin file");
	cmd("debug_rotation",     "owner",       ::cmd_DebugRotation,        "Test all maps in rotation");
	cmd("debug_save_spawn",   "owner",       ::cmd_DebugSaveSpawn,       "Test all maps and write the player spawn to file");
	cmd("debug_scriptusage",  "owner",       ::cmd_DebugScriptUsage,     "Display script memory usage");
	cmd("debug_spectate",     "owner",       ::cmd_DebugSpectate,        "Spawn a bot in spectator and autoassign in a loop");
	cmd("debug_speed",        "owner",       ::cmd_DebugSpeed,           "Display player movement variables info");
	cmd("debug_surface",      "owner",       ::cmd_DebugSurface,         "Display surface type at player aim position");
	cmd("test",               "owner",       ::cmd_Test,                 "Test function");

	if (getDvarInt("debug_rotation"))
		event("map", ::cmd_DebugRotation);

	if (getDvarInt("debug_save_spawn"))
		event("map", ::cmd_DebugSaveSpawn);
}

cmd_Bots(args)
{
	if (args.size < 1)
		return self pm("Usage: !bots <amount>");

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
	rotation = sr\core\_map::getRotation(true);
	index = IndexOf(rotation, level.map);
	map = rotation[index + 1];
	setDvar("sv_maprotationcurrent", "gametype deathrun map " + IfUndef(map, ""));

	// Next map
	if (!isDefined(map))
	{
		comPrintLn("^5Debug operation completed");
		exit(0);
	}
	levelExit(false);
}

cmd_DebugSaveSpawn(args)
{
	// Setup next map
	rotation = sr\core\_map::getRotation(true);
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
	if (!isDefined(map))
	{
		comPrintLn("^5Debug operation completed");
		exit(0);
	}
	levelExit(false);
}

cmd_DebugEntsSpawn(args)
{
	if (args.size < 1)
		return self pm("Usage: !debug_ents_spawn <amount>");

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
	self pm(fmt("Script Usage: !^5%d", debug_scriptusage()));
}

cmd_DebugOrigin(args)
{
	file = FILE_Open(PATH_Mod(fmt("data/debug/origins/%s", level.map)), "a");

	x = int(self.origin[0]);
	y = int(self.origin[1]);
	z = int(self.origin[2]) + 60;

	FILE_WriteLine(file, fmt("%d/%d/%d", x, y, z));
	FILE_Close(file);

	self pm(fmt("Saved origin: ^5%d %d %d", x, y, z));
}

cmd_DebugKZ(args)
{
	self command("bots", "1");
	self command("killzone");
	self command("cmd", "1 killzone");
}

cmd_DebugSpectate(args)
{
	bots = spawnBots(1);
	wait 1;

	while (true)
	{
		bots[0] eventSpectator(true);
		bots[0].spectatorclient = 0;

		wait 5;

		bots[0] eventSpawn(true);

		wait 5;
	}
}

cmd_ResetPasswords(args)
{
	critical_enter("mysql");

	request = SQL_Prepare("SELECT player FROM players");
	SQL_Execute(request);
	AsyncWait(request);
	rows = SQL_FetchRowsDict(request);
	SQL_Free(request);

	for (i = 0; i < rows.size; i++)
	{
		password = generateToken(9);
		request = SQL_Prepare("UPDATE players SET password = ? WHERE player = ?");
		SQL_BindParam(request, password, level.MYSQL_TYPE_STRING);
		SQL_BindParam(request, rows[i]["player"], level.MYSQL_TYPE_STRING);
		SQL_Execute(request);
		AsyncWait(request);
		SQL_Free(request);
	}
	self pm("^5Done");

	critical_release("mysql");
}

cmd_Test(args)
{

}

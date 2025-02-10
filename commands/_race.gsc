#include sr\sys\_file;
#include sr\sys\_admins;
#include sr\game\minigames\_main;
#include sr\game\minigames\_race;
#include sr\utils\_common;

main()
{
    cmd("player", 		"race",			::cmd_Race);
    cmd("adminplus", 	"race_trig",	::cmd_RaceTrig);
	cmd("adminplus", 	"race_spawn",	::cmd_RaceSpawn);
	cmd("adminplus", 	"race_mk",		::cmd_RaceMk);
	cmd("adminplus", 	"race_save",	::cmd_RaceSave);
}

cmd_Race(args)
{
	if (self isInOtherQueue("race"))
		return;

	if (!self isInQueue("race"))
		join();
	else
		leave();
}

cmd_RaceTrig(args)
{
	radius = IfUndef(ToInt(args[0]), 120);

	if (args.size)
	{
		array = getEntArray("endmap_trig", "targetname");
		if (!array.size)
			return;

		level.raceEndTrig = array[0];
		self pm("Reset race end trigger");
		return;
	}
	if (isDefined(getEnt("race_endtrig", "targetname")))
		getEnt("race_endtrig", "targetname") delete();

	trig = spawn("trigger_radius", self getOrigin(), 0, radius, 80);
	trig.targetname = "race_endtrig";

	level.raceEndTrig = trig;
	self pm("Placed race end trigger");
}

cmd_RaceSpawn(args)
{
	if (args.size)
	{
		level.raceSpawn = level.spawn["player"];
		self pm("Reset race spawn point");
		return;
	}
	spawn = spawnStruct();
	spawn.origin = self getOrigin();
	spawn.angles = self getPlayerAngles();
	level.raceSpawn = spawn;
	self pm("Placed race spawn point");
}

cmd_RaceMk(args)
{
	level.racePoints[level.racePoints.size] = self GetOrigin();
	self pm("Points placed " + level.racePoints.size);
}

cmd_RaceSave(args)
{
	file = FILE_Open(level.files["race"], "w+");
	for (i = 0; i < level.racePoints.size; i++)
	{
		origin = level.racePoints[i];

		FILE_WriteLine(file, fmt("%f/%f/%f", origin[0], origin[1], origin[2]));
	}
	FILE_Close(file);
	self pm("Points saved");

	load();
	self pm("Points loaded");
}

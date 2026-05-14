#include sr\sys\_file;
#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
    cmd("race",       "player",    ::cmd_Race,      "Join the race minigame");
    cmd("race_trig",  "adminplus", ::cmd_RaceTrig,  "Place the race end trigger");
	cmd("race_spawn", "adminplus", ::cmd_RaceSpawn, "Place the race spawn point");
	cmd("race_mk",    "adminplus", ::cmd_RaceMk,    "Place a race point");
	cmd("race_save",  "adminplus", ::cmd_RaceSave,  "Save the race configuration");
}

cmd_Race(args)
{
	if (self sr\core\_minigames::isInOtherQueue("race"))
		return;

	if (!self sr\core\_minigames::isInQueue("race"))
		sr\minigames\_race::join();
	else
		sr\minigames\_race::leave();
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

	sr\minigames\_race::load();
	self pm("Points loaded");
}

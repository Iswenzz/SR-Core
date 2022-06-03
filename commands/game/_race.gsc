#include sr\sys\_admins;
#include sr\game\minigames\_race;

main()
{
    cmd("member", 	"race",			::cmd_Race);
    cmd("admin", 	"race_trig",	::cmd_RaceTrig);
	cmd("admin", 	"race_spawn",	::cmd_RaceSpawn);
	cmd("owner", 	"race_mk",		::cmd_RaceMk);
	cmd("owner", 	"race_save",	::cmd_RaceSave);
}

cmd_Race()
{
	if (self.sr_minigame_playing)
	{
		self pm("^1Already in a different mode.");
		return;
	}
	Ternary(self.sr_minigame["race"], join(), leave());
}

cmd_RaceTrig(args)
{
	radius = IfUndef(ToInt(args[0]), 120);

	if (arg == "reset")
	{
		resetEndTrig();
		return;
	}
	if (isDefined(getEnt("race_endtrig", "targetname")))
		getEnt("race_endtrig", "targetname") delete();

	trig = spawn("trigger_radius", self getOrigin(), 0, radius, 80);
	trig.targetname = "race_endtrig";
	self setTrig();
}

cmd_RaceSpawn()
{
	if (arg == "reset")
	{
		resetSpawn();
		return;
	}
	spawn = spawnStruct();
	spawn.origin = self getOrigin();
	spawn.angles = self getPlayerAngles();
	setSpawn(spawn);
}

cmd_RaceMk()
{
	placeCheckpoint();
}

cmd_RaceSave()
{
	saveCheckpoints();
}

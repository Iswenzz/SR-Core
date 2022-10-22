#include sr\sys\_file;
#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	if (!level.dvar["demos"])
		return;

	event("spawn", ::record);
	event("death", ::recordDelete);
	event("death", ::stopDemoPlayer);
	event("disconnect", ::recordDelete);
}

play(mode, way)
{
	self stopDemoPlayer();
	wait 0.05;
	self endon("demo_stop");

	self.sr_cheat = true;
	self.godmode = true;
	self.antiLag = false;
	self.antiElevator = false;

	self endon("death");
	self endon("disconnect");
	self endon("joined_spectators");

	if (!isDefined(self.demoEnt))
	{
		self.demoEnt = self playDemo(mode, way);
		self linkTo(self.demoEnt);
	}

	self thread speedrun\player\huds\_demo::hud();

	while (self isDemoPlaying())
	{
		if (self meleeButtonPressed())
			break;

		wait 0.05;
	}
	self thread stopDemoPlayer();
}

stopDemoPlayer()
{
	if (isDefined(self.demoEnt))
	{
		self notify("demo_stop");
		self.demoEnt delete();
		self stopDemo();
		self suicide();

		self.godmode = undefined;
		self.antiLag = true;
		self.antiElevator = true;
	}
}

record()
{
	self endon("death");
	self endon("disconnect");

	if (self.isBot || self.sr_cheat)
		return;

	wait 1;

	thread recordTimeout();

	mapname = level.map;
	self.demoPath = PathJoin(PATH_Mod("sr/data/demos"), self.id, mapname, ToString(self.run));
	exec(fmt("record %d %s", self getEntityNumber(), self.demoPath));
}

recordTimeout()
{
	self endon("death");
	self endon("disconnect");
	self endon("record_done");

	wait 120;
	recordDelete();
}

recordSave()
{
	self.demoPath = undefined;
	self notify("record_done");
	exec("stoprecord " + self GetEntityNumber());
}

recordDelete()
{
	if (!isDefined(self.demoPath))
		return;

	path = self.demoPath + ".dm_1";
	exec("stoprecord " + self GetEntityNumber());

	wait 0.2;
	if (FILE_Exists(path))
		FILE_Delete(path);
}

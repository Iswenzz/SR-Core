#include sr\sys\_events;

main()
{
	event("connect", ::record);
	event("death", ::recordDelete);
	event("disconnect", ::recordDelete);
}

record()
{
	self endon("death");
	self endon("disconnect");

	if (self.isBot)
		return;

	thread recordTimeout();

	mapname = getDvar("mapname");
	self.demoPath = PathJoin(PATH_Mod("sr/data/demos"), self.id, mapname, self.runId, ".dm_1");
	exec(fmt("record %d %s", self getEntityNumber(), path));
}

recordTimeout()
{
	self endon("death");
	self endon("disconnect");

	wait 120;
	recordDelete();
}

recordSave()
{
	exec("stoprecord " + self GetEntityNumber());
}

recordDelete()
{
	if (FILE_Exists(self.demoPath))
		FILE_Remove(self.demoPath);
}

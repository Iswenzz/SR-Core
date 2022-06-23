#include sr\sys\_file;
#include sr\sys\_events;

main()
{
	if (!level.dvar["demos"])
		return;

	event("spawn", ::record);
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

	mapname = level.map;
	self.demoPath = PathJoin(PATH_Mod("sr/data/demos"), self.id, mapname, ToString(self.runId));
	comPrintLn("demo: %s", self.demoPath);
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

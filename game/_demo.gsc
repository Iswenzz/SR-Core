#include sr\sys\_file;
#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	if (!level.dvar["demos"])
		return;

	level.demos = [];

	event("spawn", ::record);
	event("death", ::recordDelete);
	event("disconnect", ::recordDelete);
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
	self.demoPath = PathJoin(PATH_Mod("demos"), self.id, mapname, ToString(self.run));
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

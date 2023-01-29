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
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (self.sr_cheat)
		return;

	thread recordTimeout();

	self.recordPath = PathJoin(PATH_Mod("demos"), self.id, level.map, self.run);
	exec(fmt("record %d %s", self getEntityNumber(), self.recordPath));
}

recordTimeout()
{
	self endon("death");
	self endon("disconnect");
	self endon("record");

	wait 120;
	recordDelete();
}

recordSave()
{
	self.recordPath = undefined;
	self notify("record");
	exec("stoprecord " + self GetEntityNumber());
}

recordDelete()
{
	if (!isDefined(self.recordPath))
		return;

	path = self.recordPath + ".dm_1";
	exec("stoprecord " + self GetEntityNumber());

	wait 0.2;
	if (FILE_Exists(path))
		FILE_Delete(path);
}

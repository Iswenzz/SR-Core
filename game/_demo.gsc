#include sr\sys\_file;
#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	if (!level.dvar["demos"])
		return;

	level.demos = [];

	event("connect", ::recordDelete);
	event("death", ::recordDelete);
	event("disconnect", ::recordDelete);
}

record()
{
	if (self isCheat())
		return;

	thread recordTimeout();

	self.pers["record_path"] = PathJoin(PATH_Mod("demos"), self.id, level.map, self.run);
	exec(fmt("record %d %s", self getEntityNumber(), self.pers["record_path"]));
}

recordTimeout()
{
	self endon("death");
	self endon("disconnect");
	self endon("record");

	wait level.dvar["demos_timeout"];
	recordDelete();
}

recordSave()
{
	self.pers["record_path"] = undefined;
	self notify("record");
	exec("stoprecord " + self GetEntityNumber());
}

recordDelete()
{
	if (!isDefined(self.pers["record_path"]))
		return;

	path = self.pers["record_path"] + ".dm_1";
	exec("stoprecord " + self GetEntityNumber());

	wait 0.2;
	if (FILE_Exists(path))
		FILE_Delete(path);
}

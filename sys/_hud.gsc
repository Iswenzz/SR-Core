#include sr\sys\_events;

initHud()
{
	level.huds = spawnStruct();

	event("connect", ::eventHud);
}

eventHud()
{
	self.huds = spawnStruct();
}

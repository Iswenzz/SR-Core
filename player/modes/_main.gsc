#include sr\sys\_events;

initModes()
{
	level.modes = [];

	event("connect", ::onConnect);
}

createMode(name)
{
	level.modes[level.modes.size] = name;
}

onConnect()
{
	self.modes = [];
	for (i = 0; i < level.modes.size; i++)
		self.modes[level.modes[i]] = false;
}

isInAnyMode()
{
	for (i = 0; i < level.modes.size; i++)
	{
		if (self.modes[level.modes[i]])
			return true;
	}
	return false;
}

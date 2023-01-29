#include sr\sys\_events;
#include sr\utils\_common;

initModes()
{
	level.modes = [];

	event("connect", ::onConnect);
}

createMode(name)
{
	level.modes[name] = name;
}

onConnect()
{
	self.modes = [];

	keys = getArrayKeys(level.modes);
	for (i = 0; i < level.modes.size; i++)
		self.modes[keys[i]] = false;
}

toggleMode(name)
{
	self.modes[name] = !self.modes[name];

	if (self.modes[name])
		self.sr_cheat = true;
}

isInMode(name)
{
	return self.modes[name];
}

isInOtherMode(name)
{
	if (self sr\game\minigames\_main::isInAnyQueue())
	{
		self pm("^1Already in a different mode.");
		return true;
	}

	keys = getArrayKeys(level.modes);
	for (i = 0; i < keys.size; i++)
	{
		if (keys[i] == name)
			continue;

		if (self isInMode(keys[i]))
		{
			self pm("^1Already in a different mode.");
			return true;
		}
	}
	return false;
}

isInAnyMode()
{
	keys = getArrayKeys(level.modes);
	for (i = 0; i < keys.size; i++)
	{
		if (self isInMode(keys[i]))
			return true;
	}
	return false;
}

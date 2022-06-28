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

toggleMode(name)
{
	self.modes[name] = !self.modes[name];
}

isInMode(name)
{
	return self.modes[name];
}

isInOtherMode(name)
{
	if (self sr\game\minigames\_main::isInAnyQueue())
	{
		self sr\sys\_admins::pm("^1Already in a different mode.");
		return true;
	}

	keys = getArrayKeys(self.modes);
	for (i = 0; i < keys.size; i++)
	{
		if (keys[i] == name)
			continue;

		if (self isInMode(keys[i]))
		{
			self sr\sys\_admins::pm("^1Already in a different mode.");
			return true;
		}
	}
	return false;
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

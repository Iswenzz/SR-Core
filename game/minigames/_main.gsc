#include sr\sys\_events;
#include sr\utils\_common;

initMinigames()
{
	level.minigames = [];

	event("disconnect", ::removeFromAllQueue);
}

createMinigame(minigame)
{
	level.minigames[minigame] = spawnStruct();
	level.minigames[minigame].name = minigame;
	level.minigames[minigame].queue = [];
}

isInQueue(minigame)
{
	return Contains(level.minigames[minigame].queue, self);
}

isInOtherQueue(minigame)
{
	if (self sr\player\modes\_main::isInAnyMode())
	{
		self pm("^1Already in a different mode.");
		return true;
	}

	keys = getArrayKeys(level.minigames);
	for (i = 0; i < keys.size; i++)
	{
		if (keys[i] == minigame)
			continue;

		if (self isInQueue(keys[i]))
		{
			self pm("^1Already in a different mode.");
			return true;
		}
	}
	return false;
}

isInAnyQueue()
{
	keys = getArrayKeys(level.minigames);
	for (i = 0; i < keys.size; i++)
	{
		if (self isInQueue(keys[i]))
			return true;
	}
	return false;
}

addToQueue(minigame)
{
	if (self isInQueue(minigame))
		return;

	self.sr_cheat = true;
	index = level.minigames[minigame].queue.size;
	level.minigames[minigame].queue[index] = self;
}

removeFromQueue(minigame)
{
	queue = Remove(level.minigames[minigame].queue, self);
	level.minigames[minigame].queue = queue;
	self minigameSpawn(undefined);
}

removeFromAllQueue()
{
	minigames = getArrayKeys(level.minigames);
	for (i = 0; i < minigames.size; i++)
		self removeFromQueue(minigames[i]);
}

pickRandomPlayers(minigame, amount)
{
	return pickRandom(level.minigames[minigame].queue, amount);
}

minigameSpawn(spawn)
{
	self.minigameSpawn = spawn;
}

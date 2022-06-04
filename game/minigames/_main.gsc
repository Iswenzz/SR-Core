#include sr\sys\_events;
#include sr\utils\_common;

main()
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
	return self isInArray(level.minigames[minigame].queue);
}

isInOtherQueue(minigame)
{
	keys = getArrayKeys(level.minigames);
	for (i = 0; i < keys.size; i++)
	{
		if (keys[i] == minigame)
			continue;

		if (self isInQueue(minigame))
			return true;
	}
	return false;
}

addToQueue(minigame)
{
	if (self isInQueue(minigame))
		return;

	index = level.minigames[minigame].queue.size;
	level.minigames[minigame].queue[index] = self;
}

removeFromQueue(minigame)
{
	queue = self removeFromArray(level.minigames[minigame].queue);
	level.minigame[minigame].queue = queue;
}

removeFromAllQueue()
{
	minigames = getArrayKeys(level.minigames);
	for (i = 0; i < level.minigames.size; i++)
		self removeFromQueue(level.minigames[minigames[i]]);
}

pickRandomPlayers(minigame, amount)
{
	players = [];
	queue = level.minigames[minigame].queue;

	while (players.size < amount)
	{
		picked = queue[randomIntRange(0, queue.size)];
		if (picked isInArray())
			continue;
		players[players.size] = picked;
	}
	return players;
}

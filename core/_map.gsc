#include sr\sys\_events;

end(map)
{
	eventEnd(map);
}

randomizeMaps(amount)
{
	maps = [];
	rotation = level.rotation;
	file = FILE_Open(level.files["rotation"], "a+");
	playedMaps = FILE_ReadLines(file);

	if (rotation.size < amount)
		return;

	// No more new maps found
	if (playedMaps.size >= rotation.size - amount)
	{
		FILE_Close(file);
		FILE_Delete(level.files["rotation"]);
		return thread randomizeMaps(amount);
	}

	while (maps.size != amount)
	{
		picked = rotation[randomInt(rotation.size)];
		rotation = Remove(rotation, picked);

		// Found map
		if (!Contains(playedMaps, picked))
		{
			maps[maps.size] = picked;
			FILE_WriteLine(file, picked);
		}
	}
	FILE_Close(file);
	level.randomizedMaps = maps;
}

getRotation(includeCurrent)
{
	file = FILE_Open(level.files["maps"], "r");
	maps = FILE_ReadLines(file);
	FILE_Close(file);

	if (!includeCurrent)
		maps = Remove(maps, level.map);

	return Sort(maps);
}

addTime(minutes)
{
	level.time += minutes * 60;
	if (isDefined(level.huds["time"]))
		level.huds["time"] setTimer(level.time);
}

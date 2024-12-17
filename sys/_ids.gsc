#include sr\sys\_file;
#include sr\sys\_events;
#include sr\utils\_common;

initIds()
{
	level.files["playerIds"] = PATH_Mod("sr/data/admin/ids.txt");
}

load()
{
	if (self isBot())
	{
		self.guid = "^5Speedrun";
		return "^8BOT";
	}
	if (self getStat(995) == 0 || self getStat(996) == 0 || self getStat(997) == 0)
	{
		id = createId();
		self setStat(995, id[0]);
		self setStat(996, id[1]);
		self setStat(997, id[2]);
		self.new = true;
	}
	return fmt("%d%d%d", self getStat(995), self getStat(996), self getStat(997));
}

// Replace with SQL
createId()
{
	file = FILE_Open(level.files["playerIds"], "a+");
	lines = FILE_ReadLines(file);

	id = [];
	idString = "";

	while (true)
	{
		id[0] = randomIntRange(1, 255);
		id[1] = randomIntRange(1, 255);
		id[2] = randomIntRange(1, 255);
		idString = fmt("%d%d%d", id[0], id[1], id[2]);

		if (!idExists(lines, idString))
			break;
	}
	FILE_WriteLine(file, idString);
	return id;
}

idExists(lines, id)
{
	for (i = 0; i < lines.size; i++)
	{
		if (lines[i] == id)
			return true;
	}
	return false;
}

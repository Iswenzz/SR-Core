initFile()
{
	level.file = spawnStruct();
}

FILE_OpenMod(path, mode)
{
	path = PathJoin(getDvar("fs_game"), path);

	if (!FILE_Exists(path))
		FILE_Create(path);

    return FILE_Open(path, mode);
}

FILE_ReadLines(file)
{
	lines = [];
	while (true)
	{
		line = FILE_ReadLine(file);

		if (IsNullOrEmpty(line))
			break;

		lines[lines.size] = line;
	}
	return lines;
}

initFile()
{
	level.file = spawnStruct();
}

PATH_Mod(path)
{
	return PathJoin(getDvar("fs_game"), path);
}

FILE_OpenMod(path, mode)
{
	path = PATH_Mod(path);

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

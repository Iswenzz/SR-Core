initFiles()
{
	level.files = [];

	FILE_MkDirMod("sr/data");
	FILE_MkDirMod("sr/data/admin");
	FILE_MkDirMod("sr/data/chickens");
	FILE_MkDirMod("sr/data/maps");
	FILE_MkDirMod("sr/data/match");
	FILE_MkDirMod("sr/data/kz");
	FILE_MkDirMod("sr/data/race");
	FILE_MkDirMod("sr/data/demos");
}

PATH_Mod(path)
{
	return PathJoin(getDvar("fs_game"), path);
}

FILE_MkDirMod(path)
{
	path = PATH_Mod(path);

	if (!FILE_Exists(path))
		FILE_MkDir(path);
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

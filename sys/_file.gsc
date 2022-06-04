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

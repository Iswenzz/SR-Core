initFile()
{
	level.file = spawnStruct();
}

FILE_OpenMod(path, mode)
{
    return FILE_Open(PathJoin(getDvar("fs_game"), path), mode);
}

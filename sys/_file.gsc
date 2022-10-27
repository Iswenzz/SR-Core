initFiles()
{
	level.files = [];

	FILE_MkDir(PATH_Mod("sr/data"));
	FILE_MkDir(PATH_Mod("sr/data/admin"));
	FILE_MkDir(PATH_Mod("sr/data/chickens"));
	FILE_MkDir(PATH_Mod("sr/data/maps"));
	FILE_MkDir(PATH_Mod("sr/data/match"));
	FILE_MkDir(PATH_Mod("sr/data/kz"));
	FILE_MkDir(PATH_Mod("sr/data/race"));
	FILE_MkDir(PATH_Mod("demos"));
}

PATH_Mod(path)
{
	return PathJoin(getDvar("fs_game"), path);
}

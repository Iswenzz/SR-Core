initFiles()
{
	level.files = [];

	level.directories = [];
	level.directories["downloads"] = PATH_Mod("data/downloads");

	FILE_MkDir(PATH_Mod("data"));
	FILE_MkDir(PATH_Mod("data/logs"));
	FILE_MkDir(PATH_Mod("data/maps"));
	FILE_MkDir(PATH_Mod("data/match"));
	FILE_MkDir(PATH_Mod("data/downloads"));

	FILE_MkDir(PATH_Mod("sr/data"));
	FILE_MkDir(PATH_Mod("sr/data/admin"));
	FILE_MkDir(PATH_Mod("sr/data/chickens"));
	FILE_MkDir(PATH_Mod("sr/data/files"));
	FILE_MkDir(PATH_Mod("sr/data/keyframes"));
	FILE_MkDir(PATH_Mod("sr/data/kz"));
	FILE_MkDir(PATH_Mod("sr/data/race"));

	FILE_MkDir(PATH_Mod("demos"));
}

PATH_Mod(path)
{
	return PathJoin(getDvar("fs_game"), path);
}

FILE_ReadAll(path)
{
	if (!FILE_Exists(path))
		return "";

	file = FILE_Open(path, "r");
	content = FILE_Read(file);
	FILE_Close(file);
	return content;
}

initFiles()
{
	level.files = [];

	level.directories = [];
	level.directories["downloads"] = PATH_Mod("sr/data/downloads");

	FILE_MkDir(PATH_Mod("sr/data"));
	FILE_MkDir(PATH_Mod("sr/data/admin"));
	FILE_MkDir(PATH_Mod("sr/data/downloads"));
	FILE_MkDir(PATH_Mod("sr/data/chickens"));
	FILE_MkDir(PATH_Mod("sr/data/json"));
	FILE_MkDir(PATH_Mod("sr/data/keyframes"));
	FILE_MkDir(PATH_Mod("sr/data/maps"));
	FILE_MkDir(PATH_Mod("sr/data/match"));
	FILE_MkDir(PATH_Mod("sr/data/kz"));
	FILE_MkDir(PATH_Mod("sr/data/race"));
	FILE_MkDir(PATH_Mod("sr/data/system"));
	FILE_MkDir(PATH_Mod("demos"));
}

PATH_Mod(path)
{
	return PathJoin(getDvar("fs_game"), path);
}

FILE_OpenJSON(path)
{
	if (!FILE_Exists(path))
		return "";
	file = FILE_Open(path, "r");

	lines = FILE_ReadLines(file);
	for (i = 0; i < lines.size; i++)
	{
		line = lines[i];
		line = Replace(line, "<string>", "%s");
		line = Replace(line, "\"<int>\"", "%d");
		line = Replace(line, "\"<float>\"", "%f");
		line = Replace(line, "\"<bool>\"", "%d");
		lines[i] = line;
	}

	FILE_Close(file);
	return StrJoin(lines, "\n");
}

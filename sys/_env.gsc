#include sr\sys\_file;

initEnvs()
{
	level.envs = [];

	buildEnvs();
}

buildEnvs()
{
	file = FILE_Open(PATH_Mod(".env"), "r");
	lines = FILE_ReadLines(file);

	for (i = 0; i < lines.size; i++)
	{
		line = lines[i];

		// Comments
		if (line.size && line[0] == ";")
			continue;

		// KV
		line = Replace(line, "\r", "");
		index = sr\utils\_common::stringIndex(line, "=");
		if (index < 1)
			continue;

		key = getSubStr(line, 0, index);
		value = getSubStr(line, index + 1, line.size);

		level.envs[key] = value;
	}
	FILE_Close(file);
}

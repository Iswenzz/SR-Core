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
		tokens = strTok(line, "=");
		if (tokens.size < 2)
			continue;

		key = tokens[0];
		value = tokens[1];

		level.envs[key] = value;
	}
	FILE_Close(file);
}

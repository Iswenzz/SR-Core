#include sr\sys\_file;

main()
{
	level.file_chicken = fmt("sr/data/chickens/%s.txt", getDvar("mapname"));

	cmd("member", 	"chicken",		::cmd_Chicken);
	cmd("owner", 	"chicken_save",	::cmd_ChickenSave);

	spawnChickens();
}

cmd_Chicken()
{
	ent = spawn("script_model", self.origin);
	ent setModel("chicken");
	ent.chicken = true;
}

cmd_ChickenSave()
{
	index = 0;
	models = getEntArray("script_model", "classname");
	file = FILE_OpenMod(level.file_chicken);

	for (i = 0; i < models.size; i++)
	{
		if (!isDefined(models[i].chicken))
			continue;

		c = models[i];

		line = fmt("%d/%f/%f/%f", index, c.origin[0], c.origin[1], c.origin[2]);
		FILE_WriteLine(file, line);
		index++;
	}
	FILE_Close(file);
}

spawnChickens()
{
	chickens = [];
	file = FILE_OpenMod(level.file_chicken);

	do
	{
		line = FILE_ReadLine(file);
		tkn = strTok(line, "/");

		if (tkn.size != 4)
			continue;

		index = ToInt(tkn[0]);
		x = ToFloat(tkn[1]);
		y = ToFloat(tkn[2]);
		z = ToFloat(tkn[3]);

		chickens[index] = spawn("script_model", (x, y, z));
		chickens[index] setModel("chicken");
	} while (line);

	FILE_Close(file);
}

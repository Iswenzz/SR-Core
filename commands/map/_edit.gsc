#include sr\sys\_admins;
#include sr\sys\_file;

main()
{
	level.file.map = fmt("sr/data/maps/%s.txt", getDvar("mapname"));
	level.file.chicken = fmt("sr/data/chickens/%s.txt", getDvar("mapname"));

	cmd("member", 	"chicken",		::cmd_Chicken);
	cmd("owner", 	"chicken_save",	::cmd_ChickenSave);
	cmd("owner",	"map_save", 	::cmd_MapSave);

	spawnChickens();
	spawnBrushes();
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
	file = FILE_OpenMod(level.file.chicken);

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

cmd_MapSave()
{
	index = 0;
	brushes = getEntArray("script_brushmodel", "classname");
	file = FILE_OpenMod(level.file.map);

	for (i = 0; i < brushes.size; i++)
	{
		targetName = brushes[i].targetname;
		ents = getEntArray(targetName, "targetname");

		for (j = 0; j < ents.size; j++)
		{
			e = ents[j];
			line = fmt("%d/%f/%f/%f/%f/%f/%f/%s/%d", index,
				e.origin[0], e.origin[1], e.origin[2],
				e.angles[0], e.angles[1], e.angles[2],
				targetName, j);
			FILE_WriteLine(file, line);
			index++;
		}
	}
	FILE_Close(file);
}

spawnBrushes()
{
	chickens = [];
	file = FILE_OpenMod(level.file.map);

	while (true)
	{
		line = FILE_ReadLine(file);
		tkn = strTok(line, "/");

		if (IsNullOrEmpty(line))
			break;
		if (tkn.size != 9)
			continue;

		index = ToInt(tkn[0]);
		x = ToFloat(tkn[1]);
		y = ToFloat(tkn[2]);
		z = ToFloat(tkn[3]);
		ax = ToFloat(tkn[4]);
		ay = ToFloat(tkn[5]);
		az = ToFloat(tkn[6]);
		brushes = getEntArray(tkn[7], "targetname");
		brush_index = ToInt(tkn[8]);

		if (isDefined(brushes[brush_index]))
		{
			brushes[brush_index].origin = (x, y, z);
			brushes[brush_index].angles = (ax, ay, az);
		}
	}
	FILE_Close(file);
}

spawnChickens()
{
	chickens = [];
	file = FILE_OpenMod(level.file.chicken);

	while (true)
	{
		line = FILE_ReadLine(file);
		tkn = strTok(line, "/");

		if (IsNullOrEmpty(line))
			break;
		if (tkn.size != 4)
			continue;

		index = ToInt(tkn[0]);
		x = ToFloat(tkn[1]);
		y = ToFloat(tkn[2]);
		z = ToFloat(tkn[3]);

		chickens[index] = spawn("script_model", (x, y, z));
		chickens[index] setModel("chicken");
	}
	FILE_Close(file);
}

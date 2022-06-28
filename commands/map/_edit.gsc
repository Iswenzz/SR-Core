#include sr\sys\_admins;
#include sr\sys\_file;

main()
{
	level.files["map"] = fmt("sr/data/maps/%s.txt", level.map);
	level.files["chicken"] = fmt("sr/data/chickens/%s.txt", level.map);

	precacheModel("chicken");

	cmd("member", 	"chicken",		::cmd_Chicken);
	cmd("owner", 	"chicken_save",	::cmd_ChickenSave);
	cmd("owner",	"map_save", 	::cmd_MapSave);

	thread spawnChickens();
	thread spawnBrushes();
}

cmd_Chicken(args)
{
	ent = spawn("script_model", self.origin);
	ent setModel("chicken");
	ent.chicken = true;
}

cmd_ChickenSave(args)
{
	index = 0;
	models = getEntArray("script_model", "classname");
	file = FILE_OpenMod(level.files["chicken"], "w+");

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

	self pm("Chickens saved!");
}

cmd_MapSave(args)
{
	index = 0;
	brushes = getEntArray("script_brushmodel", "classname");
	file = FILE_OpenMod(level.files["map"], "w+");

	for (i = 0; i < brushes.size; i++)
	{
		targetName = brushes[i].targetname;
		if (!isDefined(targetName))
			continue;
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

	self pm("Map saved!");
}

spawnBrushes()
{
	if (!FILE_ExistsMod(level.files["map"]))
		return;

	sr\utils\_common::waitMapLoad();

	file = FILE_OpenMod(level.files["map"], "r+");

	while (true)
	{
		line = FILE_ReadLine(file);
		tkn = strTok(line, "/");

		if (IsNullOrEmpty(line) || tkn.size != 8)
			break;

		origin = (ToFloat(tkn[0]), ToFloat(tkn[1]), ToFloat(tkn[2]));
		angles = (ToFloat(tkn[3]), ToFloat(tkn[4]), ToFloat(tkn[5]));
		brushes = getEntArray(tkn[6], "targetname");
		brush_index = Ternary(brushes.size > 1, ToInt(tkn[7]), 0);

		if (isDefined(brushes) && isDefined(brushes[brush_index]))
		{
			brushes[brush_index] moveTo(origin, 0.05);
			brushes[brush_index].angles = angles;
		}
	}
	FILE_Close(file);
}

spawnChickens()
{
	if (!FILE_ExistsMod(level.files["chicken"]))
		return;

	chickens = [];
	file = FILE_OpenMod(level.files["chicken"], "r+");

	while (true)
	{
		line = FILE_ReadLine(file);
		tkn = strTok(line, "/");

		if (IsNullOrEmpty(line) || tkn.size != 3)
			break;

		origin = (ToFloat(tkn[0]), ToFloat(tkn[1]), ToFloat(tkn[2]));

		index = chickens.size;
		chickens[index] = spawn("script_model", origin);
		chickens[index] setModel("chicken");
	}
	FILE_Close(file);
}

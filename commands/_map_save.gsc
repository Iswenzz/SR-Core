#include sr\sys\_admins;
#include sr\sys\_file;

main()
{
	level.file_map = fmt("sr/data/maps/%s.txt", getDvar("mapname"));

	cmd("owner", "map_save", ::cmd_MapSave);

	spawnBrushes();
}

cmd_MapSave()
{
	index = 0;
	brushes = getEntArray("script_brushmodel", "classname");
	file = FILE_OpenMod(level.file_map);

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
	file = FILE_OpenMod(level.file_map);

	do
	{
		line = FILE_ReadLine(file);
		tkn = strTok(line, "/");

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
	} while (line);

	FILE_Close(file);
}

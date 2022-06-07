initDvars()
{
	setDvar("jump_slowdownEnable", 0);
	setDvar("bullet_penetrationEnabled", 0);
	setDvar("mod_author", "SuX Lolz");
	makeDvarServerInfo("mod_author", "SuX Lolz");
}

addDvar(scriptName, varname, vardefault, min, max, type)
{
	value = getDvar(varname);

	switch (type)
	{
		case "int":		definition = Ternary(IsNullOrEmpty(value), vardefault, getDvarInt(varname));	break;
		case "float": 	definition = Ternary(IsNullOrEmpty(value), vardefault, getDvarFloat(varname));	break;
		default: 		definition = Ternary(IsNullOrEmpty(value), vardefault, value);					break;
	}
	if ((type == "int" || type == "float") && min != 0 && definition < min)
		definition = min;
	if ((type == "int" || type == "float") && max != 0 && definition > max)
		definition = max;

	if (isNullOrEmpty(value))
		setDvar(varname, definition);

	level.dvar[scriptName] = definition;
}

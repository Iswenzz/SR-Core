initDvars()
{
	level.dvar = [];

	addDvar("spawn_time", "dr_spawn_time", 4, 1, 30, "int");
	addDvar("demos", "sr_demos", 1, 0, 1, "int");
	addDvar("map_scores", "sr_map_scores", 1, 0, 1, "int");
	addDvar("map_vote", "sr_map_vote", 1, 0, 1, "int");
	addDvar("match_need_players", "sr_match_need_players", 0, 0, 10, "int");
}

reset()
{
	setDvar("g_knockback", 1000);
	setDvar("g_speed", 190);
	setDvar("g_gravity", 800);
	setDvar("jump_height", 39);
	setDvar("dr_jumpers_speed", 1.05);
	setDvar("dr_activators_speed", 1.05);
	setDvar("jump_slowdownEnable", 0);
	setDvar("bullet_penetrationEnabled", 0);

	makeDvarServerInfo("mod_author", "SuX Lolz");
	setDvar("mod_author", "SuX Lolz");
}

addDvar(scriptName, dvarName, defaultValue, min, max, type)
{
	value = getDvar(dvarName);

	switch (type)
	{
		case "int":		definition = Ternary(IsNullOrEmpty(value), defaultValue, getDvarInt(dvarName));		break;
		case "float": 	definition = Ternary(IsNullOrEmpty(value), defaultValue, getDvarFloat(dvarName));	break;
		default: 		definition = Ternary(IsNullOrEmpty(value), defaultValue, value);					break;
	}
	if ((type == "int" || type == "float") && min != 0 && definition < min)
		definition = min;
	if ((type == "int" || type == "float") && max != 0 && definition > max)
		definition = max;

	if (isNullOrEmpty(value))
		setDvar(dvarName, definition);

	// Maps use level.dvar not level.dvars
	level.dvar[scriptName] = definition;
	return definition;
}

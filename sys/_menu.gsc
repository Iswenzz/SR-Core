#include sr\sys\_events;

initMenu()
{
	level.menus = [];

	event("connect", ::eventMenu);
}

eventMenu()
{
	self endon("disconnect");

	while (true)
	{
		self waittill("menuresponse", menu, response);

		if (!isDefined(level.menus[menu]))
			continue;

		for (i = 0; i < level.menus[menu].size; i++)
		{
			script = level.menus[menu][i];

			if (script.response == response || (script.multiple && StartsWith(script.response, response)))
				[[script.callback]](response);
		}
	}
}

menu(name, response, callback)
{
	if (!isDefined(level.menus[name]))
		level.menus[name] = [];

	index = level.menus[name].size;
	level.menus[name][index] = spawnStruct();
	level.menus[name][index].name = name;
	level.menus[name][index].response = response;
	level.menus[name][index].callback = callback;
	level.menus[name][index].multiple = false;
}

menu_multiple(name, response, callback)
{
	if (!isDefined(level.menus[name]))
		level.menus[name] = [];

	index = level.menus[name].size;
	level.menus[name][index] = spawnStruct();
	level.menus[name][index].name = name;
	level.menus[name][index].response = response;
	level.menus[name][index].callback = callback;
	level.menus[name][index].multiple = true;
}

range(variable, min, max)
{
	if (variable < min)
		return max;
	if (variable > max)
		return min;
	return variable;
}

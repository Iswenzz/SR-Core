initEvents()
{
	level.events = [];
	level.menus = [];
	level.huds = spawnStruct();

	event("connect", ::eventHud);
	event("connect", ::eventMenu);
}

event(name, callback)
{
	if (!isDefined(level.events[name]))
		level.events[name] = [];

	index = level.events[name].size;
	level.events[name][index] = callback;
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

			if (script.type == "response" && script.response == response)
				[[script.callback]](response);
			if (script.type == "callback")
				[[script.callback]](response);
			if (script.type == "multiple" && StartsWith(script.response, response))
				[[script.callback]](strTok(response, ":"));
		}
	}
}

_menu(name, response, callback)
{
	if (!isDefined(level.menus[name]))
	{
		preCacheMenu(name);
		level.menus[name] = [];
	}
	index = level.menus[name].size;

	level.menus[name][index] = spawnStruct();
	level.menus[name][index].name = name;
	level.menus[name][index].response = response;
	level.menus[name][index].callback = callback;
}

menu(name, response, callback)
{
	_menu(name, response, callback);
	index = level.menus[name].size;

	level.menus[name][index].type = "response";
}

menu_multiple(name, response, callback)
{
	_menu(name, response, callback);
	index = level.menus[name].size;

	level.menus[name][index].type = "multiple";
}

menu_callback(name, callback)
{
	_menu(name, undefined, callback);
	index = level.menus[name].size;

	level.menus[name][index].type = "callback";
}

range(variable, min, max)
{
	if (variable < min)
		return max;
	if (variable > max)
		return min;
	return variable;
}

eventHud()
{
	self.huds = spawnStruct();
}

main()
{
	level.menus = [];
}

event()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("menuresponse", menu, response);

		if (isDefined(level.menus[menu]))
		{
			if (isDefined(level.menus[menu][response]))
				self thread [[level.menus[menu][response].callback]](response);
			else if (isDefined(level.menus[menu].callback) && StartsWith(level.menus[menu].response, response))
				self thread [[level.menus[menu].callback]](response);
		}
	}
}

menu(name, response, callback)
{
	level.menus[name] = spawnStruct();
	level.menus[name].name = name;
	level.menus[name].responses = [];
	level.menus[name].responses[response] = callback;
}

menu_multiple(name, response, callback)
{
	level.menus[name] = spawnStruct();
	level.menus[name].name = name;
	level.menus[name].callback = callback;
	level.menus[name].response = response;
}

range(variable, min, max)
{
	if (variable < min)
		return max;
	if (variable > max)
		return min;
	return variable;
}

initEvents()
{
	level.events = [];
	level.menus = [];
	level.huds = [];
	level.mutex = [];

	event("connect", ::connect);
}

event(name, callback)
{
	if (!isDefined(level.events[name]))
		level.events[name] = [];

	index = level.events[name].size;
	level.events[name][index] = callback;
}

connect()
{
	self endon("disconnect");
	self.huds = [];

	while (true)
	{
		self waittill("menuresponse", menu, response);

		if (!isDefined(menu) || !isDefined(level.menus[menu]))
			continue;

		for (i = 0; i < level.menus[menu].size; i++)
		{
			script = level.menus[menu][i];

			if (script.type == "response" && script.response == response)
				self thread [[script.callback]](response);
			if (script.type == "callback")
				self thread [[script.callback]](response);
			if (script.type == "multiple" && StartsWith(response, script.response))
				self thread [[script.callback]](strTok(response, ":"));
		}
	}
}

_menu(name, response, callback)
{
	if (!isDefined(level.menus[name]))
	{
		precacheMenu(name);
		level.menus[name] = [];
	}
	index = level.menus[name].size;

	level.menus[name][index] = spawnStruct();
	level.menus[name][index].name = name;
	level.menus[name][index].response = response;
	level.menus[name][index].callback = callback;
	return index;
}

menu(name, response, callback)
{
	index = _menu(name, response, callback);
	level.menus[name][index].type = "response";
}

menu_multiple(name, response, callback)
{
	index = _menu(name, response, callback);
	level.menus[name][index].type = "multiple";
}

menu_callback(name, callback)
{
	index = _menu(name, undefined, callback);
	level.menus[name][index].type = "callback";
}

eventSpawn(origin, angles)
{
	if (isDefined(origin) && isDefined(angles))
	{
		self.spawnPoint = spawnStruct();
		self.spawnPoint.origin = origin;
		self.spawnPoint.angles = angles;
	}
	self notify("spawned_player");
}

eventSpectator(origin, angles)
{
	if (isDefined(origin) && isDefined(angles))
	{
		self.spawnPoint = spawnStruct();
		self.spawnPoint.origin = origin;
		self.spawnPoint.angles = angles;
	}
	self notify("joined_spectators");
}

eventTeam()
{
	self notify("joined_team");
}

eventConnect()
{
	level notify("connected", self);
}

mutex(id, before, after)
{
	level.mutex[id] = spawnStruct();
	level.mutex[id].id = id;
	level.mutex[id].locked = false;
	level.mutex[id].before = before;
	level.mutex[id].after = after;
}

mutex_acquire(id)
{
	if (isDefined(level.mutex[id].before))
		[[level.mutex[id].before]]();

	if (level.mutex[id].locked)
		level waittill(fmt("mutex_%s", id));
	level.mutex[id].locked = true;
}

mutex_release(id)
{
	if (isDefined(level.mutex[id].after))
		[[level.mutex[id].after]]();

	level notify(fmt("mutex_%s", id));
	level.mutex[id].locked = false;
}

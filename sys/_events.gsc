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

eventSpawn(sync, spawn)
{
	if (isDefined(spawn))
		self.spawnPoint = spawn;

	self notify("spawned_player");
	if (isDefined(sync) && sync)
		self waittill("end_spawned_player");
}

eventSpectator(sync, spawn)
{
	if (isDefined(spawn))
		self.spawnPoint = spawn;
	self sr\game\_map::spawnSpectator();

	self notify("joined_spectators");
	if (isDefined(sync) && sync)
		self waittill("end_joined_spectators");
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
	level.mutex[id].locked = 0;
	level.mutex[id].before = before;
	level.mutex[id].after = after;
}

mutex_acquire(id)
{
	if (isDefined(level.mutex[id].before))
		[[level.mutex[id].before]]();

	index = level.mutex[id].locked;
	level.mutex[id].locked++;

	while (index > 0 && level.mutex[id].locked != index)
		level waittill(fmt("mutex_%s", id));
}

mutex_release(id)
{
	if (isDefined(level.mutex[id].after))
		[[level.mutex[id].after]]();

	level.mutex[id].locked--;
	level notify(fmt("mutex_%s", id));
}

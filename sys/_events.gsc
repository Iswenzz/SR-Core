initEvents()
{
	level.events = [];
	level.menus = [];
	level.huds = [];
	level.loadings = [];

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
	self endon("connect");
	self endon("disconnect");

	self.huds = [];
	self.loadings = [];

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

menu(name, response, callback)
{
	index = menu_new(name, response, callback);
	level.menus[name][index].type = "response";
}

menu_multiple(name, response, callback)
{
	index = menu_new(name, response, callback);
	level.menus[name][index].type = "multiple";
}

menu_callback(name, callback)
{
	index = menu_new(name, undefined, callback);
	level.menus[name][index].type = "callback";
}

menu_new(name, response, callback)
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

eventEnd(map)
{
	level notify("end", map);
}

eventDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	// Players already have the "damage" callback but is only executed from engine damage
	self notify("damaged", eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
}

eventSpawn(sync)
{
	self notify("spawned");
	if (isDefined(sync) && sync)
		self waittill("spawned_sync");
}

eventSpectator(sync)
{
	self notify("spectator");
	if (isDefined(sync) && sync)
		self waittill("spectator_sync");
}

setLoading(id, state)
{
	self.loadings[id] = state;
}

hasLoaded(id)
{
	return isDefined(self.loadings[id]) && !self.loadings[id];
}

loading(id)
{
	while (!self hasLoaded(id))
		wait 0.05;
}

critical(id)
{
	CriticalSection(id);
}

critical_enter(id)
{
	while (!EnterCriticalSection(id))
		wait 0.05;
}

critical_release(id)
{
	LeaveCriticalSection(id);
}

waitCriticalSections()
{
	while (!StatusCriticalSections())
		wait 0.05;
}

AsyncWait(request)
{
	status = AsyncStatus(request);
	while (status == 0 || status == 1)
	{
		wait 0.05;
		sysPrintLn("^5WAIT");
		status = AsyncStatus(request);
	}
	sysPrintLn("^5DONE");
	return status;
}

levelRestart(persist)
{
	game["ended"] = true;
	waitCriticalSections();

	map_restart(persist);
}

levelExit(persist)
{
	game["ended"] = true;
	waitCriticalSections();

	exitLevel(persist);
}

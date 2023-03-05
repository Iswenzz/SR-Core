#include sr\sys\_events;
#include sr\utils\_hud;
#include sr\utils\_math;
#include sr\utils\_common;
#include sr\player\modes\_main;

main()
{
	level.debugTriggers = false;

	createMode("debug");

	event("spawn", ::onSpawn);
	event("death", ::clean);
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (!isInMode("debug"))
		return;

	thread watchDebug();

	self huds();
	self vars();

	while (true)
	{
		wait 0.05;

		self cleanMode();

		switch (self.debugMode)
		{
			case 0: 	self debugEntities(); 	break;
			case 1: 	self debugWeapons(); 	break;
			case 2: 	self debugMaterials(); 	break;
			case 3: 	self debugSounds(); 	break;
			case 4: 	self debugMenus(); 		break;
		}
	}
}

debugMenus()
{
	self endon("debug_change");
	self setTitle("Menus");
	self setClientDvar("ui_showlist", 1);

	while (true)
	{
		self checkModeChange();
		wait 0.05;
	}
}

debugSounds()
{
	self endon("debug_change");

	self setTitle("Sounds");
	labels = strTok("3D,Stream,2D", ",");
	self setClientDvar("snd_draw3D", 3);

	groups = 0;
	prevGroups = -1;

	while (true)
	{
		self checkModeChange();

		if (self meleeButtonPressed())
		{
			while (self meleeButtonPressed())
				wait 0.05;
			groups = intRange(groups, 0, 2);
		}

		if (groups != prevGroups)
		{
			self setClientDvar("snd_drawinfo", groups + 1);
			setAction(0, fmt("^8%s: ^7[{+melee}]", labels[groups]));
		}
		wait 0.05;
	}
}

debugMaterials()
{
	self endon("debug_change");
	self setTitle("Materials");
	self setClientDvar("cg_drawmaterial", 3);

	while (true)
	{
		self checkModeChange();
		wait 0.05;
	}
}

debugEntities()
{
	self endon("debug_change");
	self setTitle("Entities");

	getTriggers();
	render = 0;
	prevEnt = undefined;

	while (true)
	{
		wait 0.05;

		self checkModeChange();
		render = intRange(render, 0, 5);

		start = self getEye();
		end = start + vectorScale(anglesToForward(self getPlayerAngles()), 99999999);
		trace = bulletTrace(start, end, false, self);
		ent = trace["entity"];

		if (render == 5)
		{
			self setInfo(0, "^8Variables:^7", debug_scriptusage());
			self countEntities();
		}
		if (!isDefined(ent))
			continue;

		targetname = IfUndef(ent.targetname, "");
		model = IfUndef(ent.model, "");

		if (isDefined(prevEnt) && ent != prevEnt)
		{
			self setInfo(5, "^5Targetname:^7", targetname);
			self setInfo(6, "^5Model:^7", model);
		}
		prevEnt = ent;
	}
}

debugWeapons()
{
	self endon("debug_change");
	self setTitle("Weapons");
	prevWeapon = "";

	while (true)
	{
		wait 0.05;

		self checkModeChange();

		weapon = self GetCurrentWeapon();
		model = GetWeaponModel(weapon, 0);

		if (weapon != prevWeapon)
		{
			self setInfo(0, "^5Weapon:^7", weapon);
			self setInfo(1, "^5Model:^7", model);
		}
		prevWeapon = weapon;
	}
}

getTriggers()
{
	if (level.debugTriggers)
		return;
	level.debugTriggers = true;

	triggers = [];
	triggers[triggers.size] = getEntArray("trigger_damage", "classname");
	triggers[triggers.size] = getEntArray("trigger_disk", "classname");
	triggers[triggers.size] = getEntArray("trigger_friendlychain", "classname");
	triggers[triggers.size] = getEntArray("trigger_hurt", "classname");
	triggers[triggers.size] = getEntArray("trigger_lookat", "classname");
	triggers[triggers.size] = getEntArray("trigger_multiple", "classname");
	triggers[triggers.size] = getEntArray("trigger_once", "classname");
	triggers[triggers.size] = getEntArray("trigger_radius", "classname");
	triggers[triggers.size] = getEntArray("trigger_use", "classname");
	triggers[triggers.size] = getEntArray("trigger_use_touch", "classname");

	for (i = 0; i < triggers.size; i++)
	{
		for (t = 0; t < triggers[i].size; t++)
			triggers[i][t] thread triggerPlayerLoop();
	}
}

countEntities()
{
	models = getEntArray("script_model", "classname").size;
	origins = getEntArray("script_origin", "classname").size;
	brushes = getEntArray("script_brushmodel", "classname").size;

	triggers = getEntArray("trigger_radius", "classname").size
		+  getEntArray("trigger_damage", "classname").size
		+  getEntArray("trigger_disk", "classname").size
		+  getEntArray("trigger_hurt", "classname").size
		+  getEntArray("trigger_multiple", "classname").size
		+  getEntArray("trigger_once", "classname").size
		+  getEntArray("trigger_use", "classname").size
		+  getEntArray("trigger_use_touch", "classname").size;

	self setInfo(1, "^8Models:^7", models);
	self setInfo(2, "^8Origins:^7", origins);
	self setInfo(3, "^8Brushes:^7", brushes);
	self setInfo(4, "^8Triggers:^7", triggers);
}

triggerPlayerLoop()
{
	level endon("debug_end");

	while (isDefined(self))
	{
		self waittill("trigger", player);

		if (!player isInMode("debug"))
			continue;
		if (!isDefined(player.debugMode) || player.debugMode != 0)
			continue;

		player setInfo(7, "^1Classname:^7", self.classname);
		player setInfo(8, "^1Trigger:^7", self.targetname);
		player setInfo(9, "^1Target:^7", self.target);

		wait 0.05;
	}
}

watchDebug()
{
	while (true)
	{
		wait 5;

		players = getAllPlayers();
		debugging = 0;

		for (i = 0; i < players.size; i++)
		{
			if (players[i] isInMode("debug"))
				debugging++;
		}
		if (!debugging)
		{
			level notify("debug_end");
			break;
		}
	}
	level.debugTriggers = false;
}

setTitle(title)
{
	self.huds["debug"]["title"] setText("^4Mode: ^7" + title);
}

setAction(index, name)
{
	action = spawnStruct();
	action.name = name;
	action.value = " ";

	if (!isDefined(self.debugActions))
		self.debugActions = [];

	self.debugActions[index] = action;
	self.huds["debug"]["actions"] setText(buildString(self.debugActions));
}

setInfo(index, name, value)
{
	info = spawnStruct();
	info.name = name;
	info.value = ToString(value);

	if (!isDefined(self.debugInfos))
		self.debugInfos = [];

	self.debugInfos[index] = info;
	self.huds["debug"]["infos"] setText(buildString(self.debugInfos));
}

buildString(entries)
{
	string = "";
	keys = Sort(getArrayKeys(entries));
	for (i = 0; i < keys.size; i++)
	{
		entry = entries[keys[i]];
		if (!IsNullOrEmpty(entry.name) && !IsNullOrEmpty(entry.value))
			string += entry.name + " " + entry.value;
		string += "\n";
	}
	return string;
}

cleanMode()
{
	self.debugActions = [];
	self.debugInfos = [];

	if (isDefined(self.huds["debug"]["actions"]))
		self.huds["debug"]["actions"] setText("");
	if (isDefined(self.huds["debug"]["infos"]))
		self.huds["debug"]["infos"] setText("");

	self setClientDvar("cg_drawmaterial", 0);
	self setClientDvar("snd_draw3D", 0);
	self setClientDvar("snd_drawinfo", 0);
	self setClientDvar("ui_showlist", 0);
}

checkModeChange()
{
	self endon("disconnect");
	self endon("death");

	if (self useButtonPressed())
	{
		self.debugMode = intRange(self.debugMode, 0, 4);
		while (self useButtonPressed())
			wait 0.05;
		self notify("debug_change");
	}
}

vars()
{
	self setClientDvars("developer", 2);
	self setClientDvars("cl_showServerCommands", 1);
	self.debugMode = 0;
}

huds()
{
	self waittill("speedrun");
	self.huds["speedrun"]["name"] setText("^8Debug");

	self.huds["debug"] = [];
	self.huds["debug"]["title"] = addHud(self, -3, 50, 1, "right", "top", 1.4, 90, true);
	self.huds["debug"]["actions"] = addHud(self, -3, 80, 1, "right", "top", 1.4, 90, true);
	self.huds["debug"]["infos"] = addHud(self, 3, -200, 1, "left", "bottom", 1.4, 90, true);
}

clean()
{
	if (isDefined(self.huds["debug"]))
	{
		self cleanMode();
		self.debugMode = undefined;
		self setClientDvar("developer", 0);
		keys = getArrayKeys(self.huds["debug"]);

		for (i = 0; i < keys.size; i++)
		{
			if (isDefined(self.huds["debug"][keys[i]]))
				self.huds["debug"][keys[i]] destroy();
		}
	}
}

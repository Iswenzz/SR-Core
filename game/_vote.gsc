#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

initVote()
{
	level.sr_map = undefined;
	level.vote_max_entries = 24;
	level.vote_maps = Chunk(level.rotation, level.vote_max_entries);
	level.vote_progress = false;
	level.vote_timer = 20;
	level.vote_yes = 0;
	level.vote_no = 0;

	menu_multiple("sr_votemap", "select", ::menu_Select);
	menu_multiple("sr_votemap", "vote", ::menu_Vote);
	menu("sr_votemap", "open", ::menu_Open);
	menu("sr_votemap", "close", ::menu_Close);
	menu("sr_votemap", "next", ::menu_PageNext);
	menu("sr_votemap", "prev", ::menu_PagePrev);
	menu("-1", "cjvoteyes", ::menu_PlayerVote);
	menu("-1", "cjvoteno", ::menu_PlayerVote);

	event("connect", ::onConnect);
}

onConnect()
{
	self endon("disconnect");

	wait 0.05;

	self.vote_cd = getTime();
	self.vote_page = 0;
	self.vote_selected = 0;
	self.vote_maps = level.vote_maps;
}

display()
{
	page = self.vote_page;
	maxPage = self.vote_maps.size;

	for (i = 0; i < level.vote_max_entries; i++)
	{
		string = "";
		if (self.vote_maps.size && isDefined(self.vote_maps[page]) && isDefined(self.vote_maps[page][i]))
			string = self.vote_maps[page][i];
		self setClientDvar("sr_votemap_" + i, string);
	}
	self setClientDvar("sr_vote_selected", "");
	self setClientDvar("sr_vote_page", fmt("%d/%d", page + 1, maxPage));
}

menu_Open(args)
{
	self.vote_maps = level.vote_maps;
	self setClientDvar("sr_vote_search", "");
	self display();

	self thread searchBox();
}

menu_Close(args)
{
	self notify("menu_votemap_close");
}

menu_PageNext(args)
{
	page = self.vote_page;
	maxPage = self.vote_maps.size;

	if (page >= maxPage - 1)
		return;

	self.vote_page++;
	self display();
}

menu_PagePrev(arg)
{
	if (self.vote_page <= 0)
		return;

	self.vote_page--;
	self display();
}

menu_Select(args)
{
	value = ToInt(args[1]);

	page = self.vote_page;
	maxPage = self.vote_maps.size;

	self.vote_selected = value;
	selected = self.vote_maps[page][value];
	self setClientDvar("sr_vote_selected", selected);
	self setClientDvar("sr_vote_selected_material", "loadscreen_" + selected);
}

menu_Vote(args)
{
	value = args[1];

	page = self.vote_page;
	selected = self.vote_maps[page][self.vote_selected];

	if ((getTime() - self.vote_cd) < 300000)
	{
		self sr\sys\_admins::pm("You cannot vote yet");
		return;
	}
	if (level.vote_progress)
	{
		self sr\sys\_admins::pm("A vote is already in progress");
		return;
	}
	if (!IsNullOrEmpty(value))
	{
		thread vote(value, selected);
		self.vote_cd = getTime();
	}
	self closeMenu();
	self closeInGameMenu();
}

// Use CJ vote binds as most people already have these.
menu_PlayerVote(arg)
{
	if (isDefined(self.sr_vote))
		return;
	self.sr_vote = true;

	switch (arg)
	{
		case "cjvoteyes": level.vote_yes++; break;
		case "cjvoteno":  level.vote_no++;  break;
	}
}

searchBox()
{
	self endon("disconnect");
	self endon("menu_votemap_close");
	previousSearch = "";

	while (true)
	{
		wait 0.2;

		self.vote_search = toLower(self getUserInfo("sr_vote_search"));
		if (previousSearch == self.vote_search)
			continue;
		previousSearch = self.vote_search;

		maps = [];
		for (i = 0; i < level.rotation.size; i++)
		{
			if (isSubStr(level.rotation[i], self.vote_search))
				maps[maps.size] = level.rotation[i];
		}
		self.vote_page = 0;
		self.vote_maps = Chunk(maps, level.vote_max_entries);
		self display();

		wait 1;
	}
}

vote(vote, value)
{
	if (level.vote_progress)
		return;
	if (vote == "src" && !isDefined(level.sr_map))
		return;

	level.vote_progress = true;
	level.vote_timer = 20;
	level.vote_yes = 0;
	level.vote_no = 0;

	// Type
	string = "";
	switch (vote)
	{
		case "map": 	string = value; 						break;
		case "endmap": 	string = "End map"; 					break;
		case "src": 	string = "^1SR-C ^7" + level.sr_map; 	break;
		case "add10": 	string = "Time +10"; 					break;
		case "add20": 	string = "Time +20"; 					break;
		case "msg": 	string = value; 						break;
	}

	// Count
	players = GetEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		players[i].sr_vote = undefined;
		players[i] thread hud(string);
	}

	// Timer
	while (level.vote_timer > 0)
	{
		level.vote_timer--;
		wait 1;
	}
	level notify("vote_ended");
	for (i = 0; i < players.size; i++)
		players[i] hudDestroy();

	// Result
	level.vote_progress = false;
	if (level.vote_yes <= level.vote_no)
	{
		level sr\sys\_notifications::message("^1Vote Failed");
		return;
	}
	level sr\sys\_notifications::message("^2Vote Passed");
	wait 2;

	// Action
	switch (vote)
	{
		case "endmap":
			thread sr\game\_map::end();
			break;

		case "map":
			thread sr\game\_map::end(string);
			break;

		case "src":
			thread sr\game\_map::end(level.sr_map);
			break;

		case "add10":
			level.time += 600;
			if (isDefined(level.huds["time"]))
				level.huds["time"] setTimer(level.time);
			break;

		case "add20":
			level.time += 1200;
			if (isDefined(level.huds["time"]))
				level.huds["time"] setTimer(level.time);
			break;
	}
}

hud(message)
{
	self.vote_hud = [];
    self.vote_hud["time"] = addHud(self, 160, -42, 1, "left", "bottom", 1.4, 96);
    self.vote_hud["title"] = addHud(self, 5, -42, 1, "left", "bottom", 1.4, 96);
	self.vote_hud["title"] setText(message);

    self.vote_hud["background"] = addHud(self, -10, 0, 0.7, "left", "bottom", 1.8);
    self.vote_hud["background"] setShader("black", 200, 40);

    self.vote_hud["header"] = addHud(self, -10, -40, 0.9, "left", "bottom", 1.8);
    self.vote_hud["header"] setShader("black", 200, 20);

    self.vote_hud["yes"] = addHud(self, 40, 0, 1, "left", "bottom", 1.4, 96);
    self.vote_hud["yes_label"] = addHud(self, 25, -20, 1, "left", "bottom", 1.4, 96);
    self.vote_hud["yes_label"] setText("Yes: (^2[{openscriptmenu cjvote cjvoteyes}]^7)");

    self.vote_hud["no"] = addHud(self, 125, 0, 1, "left", "bottom", 1.4, 96);
    self.vote_hud["no_label"] = addHud(self, 110, -20, 1, "left", "bottom", 1.4, 96);
    self.vote_hud["no_label"] setText("No: (^1[{openscriptmenu cjvote cjvoteno}]^7)");

    self hudUpdate();
}

hudUpdate()
{
	self endon("disconnect");
	level endon("vote_ended");

	while (true)
	{
		self.vote_hud["yes"] setValue(level.vote_yes);
		self.vote_hud["no"] setValue(level.vote_no);
		self.vote_hud["time"] setValue(level.vote_timer);
		wait 0.1;
	}
}

hudDestroy()
{
	if (isDefined(self.vote_hud))
	{
		keys = getArrayKeys(self.vote_hud);
		for (i = 0; i < keys.size; i++)
		{
			if (isDefined(self.vote_hud[keys[i]]))
				self.vote_hud[keys[i]] destroy();
		}
	}
}

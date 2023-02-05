#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

initVote()
{
	level.sr_map = "";
	level.voteLabels = [];
	level.voteMaxEntries = 24;
	level.voteProgress = false;
	level.voteTimer = 20;
	level.voteYes = 0;
	level.voteNo = 0;

	menu_multiple("sr_votemap", "select", ::menu_Select);
	menu_multiple("sr_votemap", "vote", ::menu_Vote);
	menu("sr_votemap", "open", ::menu_Open);
	menu("sr_votemap", "close", ::menu_Close);
	menu("sr_votemap", "next", ::menu_PageNext);
	menu("sr_votemap", "prev", ::menu_PagePrev);
	menu("-1", "cjvoteyes", ::menu_PlayerVote);
	menu("-1", "cjvoteno", ::menu_PlayerVote);

	addVote("map");
	addVote("msg");
	addVote("endmap", "End map");
	addVote("src", "^5[SR-C] ^7" + level.sr_map);
	addVote("add10", "Time +10");
	addVote("add20", "Time +20");

	event("connect", ::onConnect);
}

addVote(type, name)
{
	level.voteLabels[type] = name;
}

onConnect()
{
	self.voteCooldown = getTime();
	self.votePage = 0;
	self.voteSelected = 0;
	self.voteSearch = "";
}

display()
{
	maps = self getMaps();
	page = self.votePage;
	maxPage = maps.size;

	self.voteMaxPage = maxPage;

	for (i = 0; i < level.voteMaxEntries; i++)
	{
		string = "";
		if (maps.size && isDefined(maps[page]) && isDefined(maps[page][i]))
			string = maps[page][i];
		self setClientDvar("sr_votemap_" + i, string);
	}
	self setClientDvars(
		"sr_vote_selected", "",
		"sr_vote_page", fmt("%d/%d", page + 1, maxPage)
	);
}

menu_Open(args)
{
	self.votePage = 0;
	self.voteSelected = 0;

	self display();

	self thread searchBox();
}

menu_Close(args)
{
	self notify("votemap_close");
}

menu_PageNext(args)
{
	if (self.votePage >= self.voteMaxPage - 1)
		return;

	self.votePage++;
	self display();
}

menu_PagePrev(arg)
{
	if (self.votePage <= 0)
		return;

	self.votePage--;
	self display();
}

menu_Select(args)
{
	value = ToInt(args[1]);
	maps = self getMaps();
	page = self.votePage;

	self.voteSelected = maps[page][value];

	self setClientDvars(
		"sr_vote_selected", self.voteSelected,
		"sr_vote_selected_material", "loadscreen_" + self.voteSelected
	);
}

menu_Vote(args)
{
	type = args[1];
	page = self.votePage;

	if ((getTime() - self.voteCooldown) < 300000)
	{
		self pm("You cannot vote yet");
		return;
	}
	if (level.voteProgress)
	{
		self pm("A vote is already in progress");
		return;
	}
	if (!IsNullOrEmpty(type))
	{
		thread start(type, self.voteSelected);
		self.voteCooldown = getTime();
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
		case "cjvoteyes": level.voteYes++; break;
		case "cjvoteno":  level.voteNo++;  break;
	}
}

searchBox()
{
	self endon("disconnect");
	self endon("votemap_close");
	previousSearch = "";

	while (true)
	{
		wait 0.2;

		self.voteSearch = toLower(self getUserInfo("sr_vote_search"));
		if (previousSearch == self.voteSearch)
			continue;
		previousSearch = self.voteSearch;

		self.votePage = 0;
		self display();

		wait 1;
	}
}

getMaps()
{
	maps = [];
	for (i = 0; i < level.rotation.size; i++)
	{
		if (isSubStr(level.rotation[i], self.voteSearch))
			maps[maps.size] = level.rotation[i];
	}
	return Chunk(maps, level.voteMaxEntries);
}

start(type, value)
{
	if (type == "map" && IsNullOrEmpty(value))
		return;
	if (type == "src" && IsNullOrEmpty(level.sr_map))
		return;

	label = IfUndef(level.voteLabels[type], value);
	if (!vote(label))
		return;

	wait 2;
	switch (type)
	{
		case "endmap":	thread sr\game\_map::end();				break;
		case "map":		thread sr\game\_map::end(value);		break;
		case "src":		thread sr\game\_map::end(level.sr_map);	break;
		case "add10":	thread sr\game\_map::addTime(10);		break;
		case "add20":	thread sr\game\_map::addTime(20);		break;
	}
}

vote(label)
{
	if (level.voteProgress || game["state"] == "end")
		return false;

	level.voteProgress = true;
	level.voteTimer = 20;
	level.voteYes = 0;
	level.voteNo = 0;

	players = GetEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		players[i].sr_vote = undefined;
		players[i] thread hud(label);
	}
	while (level.voteTimer > 0)
	{
		level.voteTimer--;
		wait 1;
	}
	level notify("vote_ended");
	for (i = 0; i < players.size; i++)
		players[i] clean();

	level.voteProgress = false;
	if (level.voteYes <= level.voteNo)
	{
		level sr\sys\_notifications::show("^1Vote Failed");
		return false;
	}
	level sr\sys\_notifications::show("^2Vote Passed");
	return true;
}

hud(message)
{
    self.huds["vote"]["time"] = addHud(self, 160, -42, 1, "left", "bottom", 1.4, 96);
    self.huds["vote"]["title"] = addHud(self, 5, -42, 1, "left", "bottom", 1.4, 96);
	self.huds["vote"]["title"] setText(message);

    self.huds["vote"]["background"] = addHud(self, -10, 0, 0.7, "left", "bottom", 1.8);
    self.huds["vote"]["background"] setShader("black", 200, 40);

    self.huds["vote"]["header"] = addHud(self, -10, -40, 0.9, "left", "bottom", 1.8);
    self.huds["vote"]["header"] setShader("black", 200, 20);

    self.huds["vote"]["yes"] = addHud(self, 40, 0, 1, "left", "bottom", 1.4, 96);
    self.huds["vote"]["yes_label"] = addHud(self, 25, -20, 1, "left", "bottom", 1.4, 96);
    self.huds["vote"]["yes_label"] setText("Yes: (^2[{openscriptmenu cjvote cjvoteyes}]^7)");

    self.huds["vote"]["no"] = addHud(self, 125, 0, 1, "left", "bottom", 1.4, 96);
    self.huds["vote"]["no_label"] = addHud(self, 110, -20, 1, "left", "bottom", 1.4, 96);
    self.huds["vote"]["no_label"] setText("No: (^1[{openscriptmenu cjvote cjvoteno}]^7)");

    self hudUpdate();
}

hudUpdate()
{
	self endon("disconnect");
	level endon("vote_ended");

	while (true)
	{
		self.huds["vote"]["yes"] setValue(level.voteYes);
		self.huds["vote"]["no"] setValue(level.voteNo);
		self.huds["vote"]["time"] setValue(level.voteTimer);
		wait 0.1;
	}
}

clean()
{
	if (isDefined(self) && isDefined(self.huds["vote"]))
	{
		keys = getArrayKeys(self.huds["vote"]);
		for (i = 0; i < keys.size; i++)
		{
			if (isDefined(self.huds["vote"][keys[i]]))
				self.huds["vote"][keys[i]] destroy();
		}
	}
}

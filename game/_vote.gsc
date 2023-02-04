#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

initVote()
{
	level.sr_map = undefined;
	level.voteMaxEntries = 24;
	level.voteMaps = Chunk(level.rotation, level.voteMaxEntries);
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

	event("connect", ::onConnect);
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
	value = args[1];
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
	if (!IsNullOrEmpty(value))
	{
		thread vote(value, self.voteSelected);
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

vote(vote, value)
{
	if (level.voteProgress || game["state"] == "end")
		return;
	if (vote == "src" && !isDefined(level.sr_map))
		return;

	level.voteProgress = true;
	level.voteTimer = 20;
	level.voteYes = 0;
	level.voteNo = 0;

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
	while (level.voteTimer > 0)
	{
		level.voteTimer--;
		wait 1;
	}
	level notify("vote_ended");
	for (i = 0; i < players.size; i++)
		players[i] hudDestroy();

	// Result
	level.voteProgress = false;
	if (level.voteYes <= level.voteNo)
	{
		level sr\sys\_notifications::show("^1Vote Failed");
		return;
	}
	level sr\sys\_notifications::show("^2Vote Passed");
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

hudDestroy()
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

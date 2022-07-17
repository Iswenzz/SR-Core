#include sr\sys\_events;
#include sr\utils\_hud;

initVote()
{
	level.sr_map = "mp_sr_backrooms";
	level.vote_max_entries = 24;
	level.vote_maps = Chunk(level.rotation, level.vote_max_entries);
	level.vote_progress = false;
	level.vote_timer = 20;
	level.vote_yes = 0;
	level.vote_no = 0;

	menu_multiple("sr_votemap", "select", ::menu_Select);
	menu_multiple("sr_votemap", "vote", ::menu_Vote);
	menu("sr_votemap", "next", ::menu_PageNext);
	menu("sr_votemap", "prev", ::menu_PagePrev);
	menu("-1", "cjvoteyes", ::menu_PlayerVote);
	menu("-1", "cjvoteno", ::menu_PlayerVote);

	event("connect", ::onConnect);
}

onConnect()
{
	self endon("disconnect");

	self.vote_cd = getTime();
	self.vote_page = 0;
	self.vote_selected = 0;

	self display();
}

display()
{
	page = self.vote_page;
	maxPage = level.vote_maps.size;

	for (i = 0; i < level.vote_max_entries; i++)
	{
		string = "";
		if (isDefined(level.vote_maps[page][i]))
			string = level.vote_maps[page][i];
		self setClientDvar("sr_votemap_" + i, string);

		if (!(i % 6))
			wait 0.05;
	}
	self setClientDvar("sr_vote_selected", "");
	self setClientDvar("sr_vote_page", fmt("%d/%d", page + 1, maxPage));
}

menu_PageNext(arg)
{
	page = self.vote_page;
	maxPage = level.vote_maps.size;

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
	maxPage = level.vote_maps.size;

	self.vote_selected = value;
	selected = level.vote_maps[page][value];
	self setClientDvar("sr_vote_selected", selected);
	self setClientDvar("sr_vote_selected_material", "loadscreen_" + selected);
}

menu_Vote(args)
{
	value = args[1];

	page = self.vote_page;
	selected = level.vote_maps[page][self.vote_selected];

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

vote(vote, value)
{
	if (level.vote_progress)
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
		IPrintLnBold("^1Vote Failed");
		return;
	}
	IPrintLnBold("^2Vote Passed");
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
			level.huds["time"] setTimer(level.time);
			break;

		case "add20":
			level.time += 1200;
			level.huds["time"] setTimer(level.time);
			break;
	}
}

hud(message)
{
	self.vote_hud = [];
    self.vote_hud[0] = addHud(self, -10, 0, 0.7, "left", "bottom", 1.8);
    self.vote_hud[0] setShader("black", 180, 20);

    self.vote_hud[1] = addHud(self, -10, -20, 0.7, "left", "bottom", 1.8);
    self.vote_hud[1] setShader("black", 180, 20);

    self.vote_hud[2] = addHud(self, -10, -40, 0.9, "left", "bottom", 1.8);
    self.vote_hud[2] setShader("black", 180, 20);

    self.vote_hud[3] = addHud(self, 25, -20, 1, "left", "bottom", 1.4, 96);
    self.vote_hud[3] setText("Yes:(^2[{openscriptmenu cjvote cjvoteyes}]^7)");

    self.vote_hud[4] = addHud(self, 95, -20, 1, "left", "bottom", 1.4, 96);
    self.vote_hud[4] setText("No:(^1[{openscriptmenu cjvote cjvoteno}]^7)");

    self.vote_hud[5] = addHud(self, 35, 0, 1, "left", "bottom", 1.4, 96);
    self.vote_hud[6] = addHud(self, 105, 0, 1, "left", "bottom", 1.4, 96);
    self.vote_hud[7] = addHud(self, 5, -42, 1, "left", "bottom", 1.4, 96);
    self.vote_hud[7] setText(message);

    self.vote_hud[8] = addHud(self, 135, -42, 1, "left", "bottom", 1.4, 96);
    self hudUpdate();
}

hudUpdate()
{
	self endon("disconnect");
	level endon("vote_ended");

	while (true)
	{
		self.vote_hud[5] setText(level.vote_yes);
		self.vote_hud[6] setText(level.vote_no);
		self.vote_hud[8] setText("" + level.vote_timer);
		wait 0.1;
	}
}

hudDestroy()
{
	if (isDefined(self.vote_hud))
	{
		for (i = 0; i < self.vote_hud.size; i++)
			self.vote_hud[i] destroy();
	}
}

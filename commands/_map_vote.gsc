#include sr\sys\_admins;

main()
{
	level.vote_maps = load(false);
	level.vote_max_entries = 24;

	cmd("adminplus", 	"vote", 		::cmd_Vote);
	cmd("masteradmin", 	"vote_cancel", 	::cmd_VoteCancel);
	cmd("adminplus", 	"vote_cd", 		::cmd_VoteCooldown);
	cmd("masteradmin", 	"vote_force", 	::cmd_VoteForce);
}

event()
{
	self.vote_page = 0;
	self display();
	self thread onMenuResponse();
}

cmd_Vote(args)
{
	if (args.size < 1)
		return self pm("Usage: vote <value>");

	value = args[0];
	type = Ternary(StartsWith(value, "mp_"), "map", "msg");

	self log();
	vote(type, value);
}

cmd_VoteCancel()
{
	level notify("vote_ended");
	level.vote_no = 9999;
	level.vote_timer = 0;
}

cmd_VoteCooldown()
{
	self.vote_cd = -1000000;
	self pm("^6Vote CD cleared");
}

cmd_VoteForce()
{
	level notify("vote_ended");
	level.vote_yes = 9999;
	level.vote_timer = 0;
}

load(includeCurrent)
{
	list = [];
	currentMap = getDvar("mapname");
	maps = StrTok(getDvar("sv_maprotation"), " ");

	for (i = 0; i < maps.size; i++)
	{
		if (currentMap == maps[i] && !includeCurrent)
			continue;
		list[list.size] = maps[i];
	}
	return Chunk(list, level.vote_max_entries);
}

display()
{
	maps = level.vote_maps;
	page = self.vote_page;
	maxPage = maps.size / level.vote_max_entries;

	for (i = 0; i < level.vote_max_entries; i++)
		self setClientDvar("sr_votemap_" + i, maps[page][i]);
	self setClientDvar("sr_vote_page", fmt("%d/%d", page + 1, maxPage));
}

displayClear()
{
	for (i = 0; i < level.vote_max_entries; i++)
		self setClientDvar("sr_votemap_" + i, "");
}

onMenuResponse()
{
	self endon("disconnect");
	self notify("votemenu_end");
	self endon("votemenu_end");

	page = self.vote_page;
	maxPage = level.vote_maps.size / level.vote_max_entries;

	selected = undefined;
	self setClientDvar("sr_vote_selected", "");
	self setClientDvar("sr_vote_page", fmt("%d/%d", page + 1, maxPage));

	while (true)
	{
		self waittill("onMenuResponse", menu, response);
		if(menu != "sr_votemap")
			continue;

		args = strTok(response, ":");
		action = args[0];
		value = args[1];

		if(action == "page")
		{
			if (value == "next" && page < maxPage - 1)
			{
				self.vote_page++;
				self displayClear();
				self display();
			}
			else if (value == "prev" && page > 0)
			{
				self.vote_page--;
				self displayClear();
				self display();
			}
		}
		if (action == "votemap")
		{
			num = ToInt(value) + (page * level.vote_max_entries);
			selected = level.vote_maps[num];
			self setClientDvar("sr_vote_selected", selected);
			self setClientDvar("sr_vote_selected_material", "loadscreen_" + selected);
		}
		if (action == "callvote")
		{
			if ((gettime() - self.vote_cd) < 300000)
				self IPrintLnBold("You cannot vote yet");
			if (level.vote_progress)
				self IPrintLnBold("A vote is already in progress");
			if (!IsNullOrEmpty(value))
			{
				thread vote(value, selected);
				self.vote_cd = getTime();
			}
			self closeMenu();
			self closeInGameMenu();
		}
	}
}

vote(vote, value)
{
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
		players[i] thread watchVotes();
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
			time = level.sr_time;
			time += 600;
			level.hud_time setTimer(time);
			level notify("time_update");
			break;

		case "add20":
			time = level.sr_time;
			time += 1200;
			level.hud_time setTimer(time);
			level notify("time_update");
			break;
	}
}

// Use CJ vote binds as most people already have these.
watchVotes()
{
	self endon("disconnect");
	level endon("vote_ended");

	self.sr_vote = undefined;
	while (true)
	{
		self waittill("onMenuResponse", menu, response);
		if (response == "cjvoteyes")
		{
			level.vote_yes++;
			break;
		}
		if (response == "cjvoteno")
		{
			level.vote_no++;
			break;
		}
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

    self.vote_hud[3] = addHud(self, 25, -20, 1, "left", "bottom", 1.4);
    self.vote_hud[3] setText("Yes:(^2[{openscriptmenu cjvote cjvoteyes}]^7)");
    self.vote_hud[3].sort = 96;

    self.vote_hud[4] = addHud(self, 95, -20, 1, "left", "bottom", 1.4 );
    self.vote_hud[4] setText("No:(^1[{openscriptmenu cjvote cjvoteno}]^7)");
    self.vote_hud[4].sort = 96;

    self.vote_hud[5] = addHud(self, 35, 0, 1, "left", "bottom", 1.4);
    self.vote_hud[5].sort = 96;

    self.vote_hud[6] = addHud(self, 105, 0, 1, "left", "bottom", 1.4);
    self.vote_hud[6].sort = 96;

    self.vote_hud[7] = addHud(self, 5, -42, 1, "left", "bottom", 1.4);
    self.vote_hud[7] setText(message);
    self.vote_hud[7].sort = 96;

    self.vote_hud[8] = addHud(self, 135, -42, 1, "left", "bottom", 1.4);
    self.vote_hud[8].sort = 96;
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

addHud(who, x, y, alpha, alignX, alignY, fontScale )
{
    if (isPlayer(who))
        hud = newClientHudElem(who);
    else
        hud = newHudElem();

    hud.x = x;
    hud.y = y;
    hud.alpha = alpha;
    hud.alignX = alignX;
    hud.alignY = alignY;
    hud.horzAlign = alignX;
    hud.vertAlign = alignY;
    hud.fontScale = fontScale;
    return hud;
}

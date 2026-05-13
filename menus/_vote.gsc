#include sr\sys\_events;
#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	menu_multiple("sr_votemap", "select", ::menu_Select);
	menu_multiple("sr_votemap", "vote", ::menu_Vote);
	menu("sr_votemap", "open", ::menu_Open);
	menu("sr_votemap", "close", ::menu_Close);
	menu("sr_votemap", "next", ::menu_PageNext);
	menu("sr_votemap", "prev", ::menu_PagePrev);
	menu("-1", "cjvoteyes", ::menu_PlayerVote);
	menu("-1", "cjvoteno", ::menu_PlayerVote);
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
	maps = self sr\core\_vote::getMaps();
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
		thread sr\core\_vote::start(type, self.voteSelected);
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

display()
{
	maps = self sr\core\_vote::getMaps();
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

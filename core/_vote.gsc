#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

main()
{
	level.sr_map = "";
	level.voteLabels = [];
	level.voteMaxEntries = 24;
	level.voteProgress = false;
	level.voteTimer = 20;
	level.voteYes = 0;
	level.voteNo = 0;

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
		case "endmap":	thread sr\core\_map::end();				break;
		case "map":		thread sr\core\_map::end(value);		break;
		case "src":		thread sr\core\_map::end(level.sr_map);	break;
		case "add10":	thread sr\core\_map::addTime(10);		break;
		case "add20":	thread sr\core\_map::addTime(20);		break;
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
		level sr\huds\_notifications::show("^1Vote Failed");
		return false;
	}
	level sr\huds\_notifications::show("^2Vote Passed");
	return true;
}

hud(message)
{
    self.huds["vote"]["time"] = addHud(self, 160, -42, 1, "left", "bottom", 1.4, 96);
    self.huds["vote"]["title"] = addHud(self, 5, -42, 1, "left", "bottom", 1.4, 96);
	self.huds["vote"]["title"] setText(message);

    self.huds["vote"]["background"] = addHud(self, -10, 0, 1, "left", "bottom", 1.8);
    self.huds["vote"]["background"].color = (0, 0, 0);
    self.huds["vote"]["background"] setShader("sr_bokeh_multiply", 200, 60);

    self.huds["vote"]["header"] = addHud(self, -10, -40, 0.5, "left", "bottom", 1.8);
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

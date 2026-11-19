#include sr\sys\_events;
#include sr\utils\_common;

// Mario Kart, raced on foot (stat 1701 == 1): CPM's steering at the game's 150cc speed, where the limit is the
// player's move speed.
main()
{
	sr\core\_minigames::createMinigame("mkw");

	// The game's units a frame in ours a second: the Flame Runner under Funky Kong, a mushroom, a ramp.
	level.mkSpeed = 1488;
	level.mkBoost = 2037;
	level.mkRamp = 1935;
	precacheModel("tag_origin");

	sr\minigames\_mkw_items::main();
	sr\minigames\_mkw_race::main();

	event("spawn", ::onSpawn);
	event("map", ::course);
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (!self sr\core\_minigames::isInQueue("mkw"))
		return;

	self waittill("speedrun");
	self takeAllWeapons();
	self speedrun\huds\_speedrun::hide();
	self setClientDvars("cg_thirdPerson", 0, "cg_thirdPersonRange", 120, "cg_thirdPersonAngle", 0);
	self setGravity(800);
	self setJumpHeight(39);
	self thread sr\minigames\_mkw_items::carry();
}

// A course's boost panels and ramps: a racer on one is given its boost.
course()
{
	wait 3;
	panels = getEntArray("iz_boost", "targetname");
	for (i = 0; i < panels.size; i++)
		panels[i] thread panel(1000, level.mkBoost);

	ramps = getEntArray("iz_jump", "targetname");
	for (i = 0; i < ramps.size; i++)
		ramps[i] thread panel(750, level.mkRamp);
}

panel(time, limit)
{
	for (;;)
	{
		self waittill("trigger", player);
		if (!isPlayer(player) || !isAlive(player) || !player sr\core\_minigames::isInQueue("mkw"))
			continue;
		player sr\minigames\_mkw_items::boost(time, limit);
	}
}

// What a racer moves as from the next spawn on.
mount()
{
	self.sr_movement = 1;
}

join()
{
	self sr\core\_minigames::addToQueue("mkw");
	self mount();

	self message(fmt("%s ^7joined the Mario Kart race! [^1!mkw^7] [^1%d^7]",
		self.name, level.minigames["mkw"].queue.size));
	if (sr\minigames\_round::running("mkw"))
	{
		self pm("A race is on: you watch it and run in the next.");
		self thread sr\minigames\_round::watch();
		return;
	}
	self suicide();
}

leave()
{
	self sr\core\_minigames::removeFromQueue("mkw");
	self.sr_movement = undefined;
	self.mkRacing = undefined;
	self.mkRank = undefined;
	self sr\minigames\_mkw_race::clean();
	self sr\minigames\_mkw_items::clean();
	self freezeControls(false);
	self setClientDvars("cg_thirdPerson", 0, "cg_thirdPersonRange", 120, "cg_thirdPersonAngle", 0);

	self pm("You left the race!");
	if (self.pers["team"] == "spectator")
		self thread sr\minigames\_round::back();
	else
		self suicide();
}

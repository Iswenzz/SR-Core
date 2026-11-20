#include sr\sys\_events;
#include sr\utils\_common;

// Mario Kart, raced on foot (stat 1701 == 1): CPM's steering at the game's 150cc speed, where the limit is the
// player's move speed.
main()
{
	sr\core\_minigames::createMinigame("mkw");

	// The game's units a frame in ours a second: the Flame Runner under Funky Kong, a mushroom, a ramp, and a
	// mini-turbo's 1.2 times the speed.
	level.mkSpeed = 1488;
	level.mkBoost = 2037;
	level.mkRamp = 1935;
	level.mkTurbo = 1786;
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
	self thread turbo();
}

// Mario Kart's own ways past the run's speed. The mini-turbo: sprint held through a turn at speed charges it,
// one way round as a drift goes, and letting go fires it, blue once charged and orange, twice as long, held
// longer. The slipstream: two seconds close in another racer's wake.
turbo()
{
	self endon("disconnect");
	self endon("death");
	self endon("spawned");

	hud = sr\utils\_hud::addHud(self, 8, 84, 1, "left", "top", 1.4, 4);
	hud setText("");
	self thread sr\minigames\_mkw_items::hudEnd(hud);

	charge = 0;
	side = 0;
	draft = 0;
	shown = "";
	yaw = self getPlayerAngles()[1];
	for (;;)
	{
		wait 0.05;
		turn = self getPlayerAngles()[1] - yaw;
		yaw += turn;
		while (turn > 180)
			turn -= 360;
		while (turn < -180)
			turn += 360;
		run = self getVelocity();
		fast = length((run[0], run[1], 0)) > level.mkSpeed * 0.8;
		free = !self sr\minigames\_mkw_race::held();

		if (free && self sprintButtonPressed())
		{
			// The first turn sets which way the drift goes; turning back charges nothing.
			if (!side && turn >= 1)
				side = 1;
			if (!side && turn <= -1)
				side = -1;
			if (fast && side && turn * side >= 1)
				charge += 50;
		}
		else
		{
			if (charge >= 1600)
				self sr\minigames\_mkw_items::boost(1500, level.mkTurbo);
			else if (charge >= 800)
				self sr\minigames\_mkw_items::boost(750, level.mkTurbo);
			charge = 0;
			side = 0;
		}

		if (free && fast && self wake())
			draft += 50;
		else
			draft = 0;
		if (draft >= 2000)
		{
			draft = 0;
			self sr\minigames\_mkw_items::boost(1500, level.mkTurbo);
		}

		text = "";
		if (charge >= 1600)
			text = "^3MINI-TURBO";
		else if (charge >= 800)
			text = "^5MINI-TURBO";
		else if (draft >= 1000)
			text = "^7SLIPSTREAM";
		if (text != shown)
		{
			shown = text;
			hud setText(text);
		}
	}
}

// Close behind another racer who runs fast, in the line they run along.
wake()
{
	racers = level.minigames["mkw"].queue;
	for (i = 0; i < racers.size; i++)
	{
		other = racers[i];
		if (other == self || !isAlive(other) || other.sessionstate != "playing")
			continue;
		run = other getVelocity();
		run = (run[0], run[1], 0);
		if (length(run) < level.mkSpeed * 0.8)
			continue;
		way = vectorNormalize(run);
		to = self.origin - other.origin;
		behind = 0 - vectorDot(to, way);
		aside = length((to[0], to[1], 0) + way * behind);
		if (behind > 60 && behind < 700 && aside < 90 && abs(to[2]) < 100)
			return true;
	}
	return false;
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

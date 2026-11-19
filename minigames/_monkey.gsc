#include sr\sys\_events;
#include sr\utils\_common;

// Monkey Ball in rounds: everyone who asked for a ball at the start together, a countdown, and the goal to
// reach. A ball that falls out of the stage is out and watches the rest.
main()
{
	sr\core\_minigames::createMinigame("monkey");

	// Clear all round, no player's colour on it.
	level.monkeyBalls = strTok("clear", ",");
	for (i = 0; i < level.monkeyBalls.size; i++)
		precacheModel("smb_ball_" + level.monkeyBalls[i]);
	precacheModel("tag_origin");

	level.monkeyRound = undefined;
	event("spawn", ::onSpawn);
	sr\minigames\_round::create("monkey", "^3Monkey Ball", ::play);
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (!self sr\core\_minigames::isInQueue("monkey"))
		return;

	self setClientDvars("cg_thirdPerson", 1, "cg_thirdPersonRange", 220, "cg_thirdPersonAngle", 0);

	self waittill("speedrun");
	// With a weapon in hand the body no longer turns with the ball.
	self takeAllWeapons();
	self speedrun\huds\_speedrun::hide();

	// The player's own body, animated as ever, is turned with the ball by whoever draws it.
	ball = level.monkeyBalls[self getEntityNumber() % level.monkeyBalls.size];
	self thread sr\minigames\_ride::ride("smb_ball_" + ball);
}

join()
{
	self sr\core\_minigames::addToQueue("monkey");
	self.sr_movement = 2;

	self message(fmt("%s ^7joined monkey ball! [^3!monkey^7] [^1%d^7]",
		self.name, level.minigames["monkey"].queue.size));
	if (sr\minigames\_round::running("monkey"))
	{
		self pm("A round is on: you watch it and roll in the next.");
		self thread sr\minigames\_round::watch();
		return;
	}
	self suicide();
}

leave()
{
	self sr\core\_minigames::removeFromQueue("monkey");
	self.sr_movement = undefined;
	self.monkeyIn = undefined;
	self.monkeyDone = undefined;
	self.monkeyOut = undefined;
	self freezeControls(false);
	self setClientDvars("cg_thirdPerson", 0, "cg_thirdPersonRange", 120, "cg_thirdPersonAngle", 0);

	self pm("You left the ball!");
	if (self.pers["team"] == "spectator")
		self thread sr\minigames\_round::back();
	else
		self suicide();
}

// In the round that is on, and neither at the goal nor out.
rolling()
{
	return isDefined(level.monkeyRound) && level.monkeyRound.started && isDefined(self.monkeyIn)
		&& !isDefined(self.monkeyDone) && !isDefined(self.monkeyOut);
}

// One round, there until it is over.
play()
{
	level.monkeyRound = spawnStruct();
	level.monkeyRound.started = false;
	level.monkeyRound.finished = 0;
	level thread run();
	level waittill("monkey_over");
}

run()
{
	players = level.minigames["monkey"].queue;
	for (i = 0; i < players.size; i++)
	{
		players[i].monkeyIn = true;
		players[i].monkeyDone = undefined;
		players[i].monkeyOut = undefined;
		players[i] thread ready();
	}
	sr\minigames\_round::announce("monkey", "^3Monkey Ball: ^7first to the goal");
	wait 2;
	sr\minigames\_round::countdown("monkey");

	level.monkeyRound.started = true;
	level.monkeyRound.time = getTime();
	players = roundList();
	for (i = 0; i < players.size; i++)
	{
		players[i] freezeControls(false);
		players[i] thread fall();
	}

	// Over when no ball is left rolling, half a minute after the first goal, or after five minutes.
	first = undefined;
	for (;;)
	{
		wait 0.5;
		players = roundList();
		left = 0;
		for (i = 0; i < players.size; i++)
		{
			if (players[i] rolling())
				left++;
		}
		if (level.monkeyRound.finished && !isDefined(first))
			first = getTime();
		if (!left || (isDefined(first) && getTime() - first > 30000))
			break;
		if (getTime() - level.monkeyRound.time > 300000)
			break;
	}
	if (!level.monkeyRound.finished)
		sr\minigames\_round::announce("monkey", "^1Nobody reached the goal");
	wait 1;

	players = roundList();
	for (i = 0; i < players.size; i++)
	{
		players[i].monkeyIn = undefined;
		players[i].monkeyDone = undefined;
		players[i].monkeyOut = undefined;
		players[i] freezeControls(false);
	}
	level.monkeyRound = undefined;
	level notify("monkey_over");
}

roundList()
{
	list = [];
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		if (isDefined(players[i].monkeyIn))
			list[list.size] = players[i];
	}
	return list;
}

// At the start and held there until the countdown is through.
ready()
{
	self endon("disconnect");

	self sr\minigames\_round::muster();
	while (isDefined(level.monkeyRound) && !level.monkeyRound.started && isDefined(self.monkeyIn))
	{
		self freezeControls(true);
		wait 0.1;
	}
}

// A ball that dies, by falling out of the stage or any other way, is out of the round and watches the rest.
fall()
{
	self endon("disconnect");
	level endon("monkey_over");

	self waittill("death");
	if (!isDefined(self.monkeyIn) || isDefined(self.monkeyDone))
		return;
	self.monkeyOut = true;
	sr\minigames\_round::announce("monkey", self.name + " ^1fell out");

	// The mod spawns whoever dies at once; out of the round, it is from the stands.
	wait 0.05;
	if (self sr\core\_minigames::isInQueue("monkey"))
		self sr\minigames\_round::watch();
}

// A run's end is the goal while a round is on.
goal()
{
	level.monkeyRound.finished++;
	self.monkeyDone = level.monkeyRound.finished;

	time = (getTime() - level.monkeyRound.time) / 1000;
	sr\minigames\_round::announce("monkey", "^3" + self.monkeyDone + ". ^7" + self.name + " ^3" + time + "s");
	self freezeControls(true);
	self setBallSolid(false);
}

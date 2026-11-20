#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

// The round a lobby of racers runs: everyone who asked to race on the grid, a countdown, the laps, the
// places. A course's own gates count the laps; a map without them is one run to its end.
main()
{
	level.mkRace = undefined;
	level.mkLaps = 3;
	event("spawn", ::onSpawn);
	sr\minigames\_round::create("mkw", "^3Mario Kart", ::play);
}

racing()
{
	return isDefined(level.mkRace) && isDefined(self.mkRacing);
}

// Stood still by the race: on the grid before the start, or over the line after it.
held()
{
	return self racing() && (!level.mkRace.started || isDefined(self.mkDone));
}

// An admin's start: the laps raced from now on, and the next race without the lobby's wait.
start(laps)
{
	level.mkLaps = laps;
	if (isDefined(level.mkRace))
		stop();
	sr\minigames\_round::now("mkw");
}

// One race, there until it is over or stopped.
play()
{
	level.mkRace = spawnStruct();
	level.mkRace.laps = level.mkLaps;
	level.mkRace.started = false;
	level.mkRace.finished = 0;
	level.mkRace.gates = isDefined(level.iz_course_gates) && level.iz_course_gates > 0;
	if (!level.mkRace.gates)
		level.mkRace.laps = 1;
	level thread run();
	level waittill("mk_race_over");
}

stop()
{
	if (!isDefined(level.mkRace))
		return;
	level notify("mk_race_stop");

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		if (!isDefined(players[i].mkRacing))
			continue;
		players[i].mkRacing = undefined;
		players[i].mkRank = undefined;
		players[i] freezeControls(false);
		players[i] clean();
		players[i] notify("mk_orbit");
		players[i] sr\minigames\_mkw_items::lose();
	}
	sr\minigames\_mkw_items::clear();
	level.mkRace = undefined;
	sr\minigames\_round::announce("mkw", "^3Race over");
	level notify("mk_race_over");
}

run()
{
	level endon("mk_race_stop");

	// Everyone who asked to race starts, whoever watched the last race too.
	racers = level.minigames["mkw"].queue;
	for (i = 0; i < racers.size; i++)
	{
		racers[i].mkRacing = true;
		racers[i].mkLap = 1;
		racers[i].mkGate = 0;
		racers[i].mkSafe = undefined;
		racers[i].mkDone = undefined;
		racers[i].mkRank = undefined;
		racers[i].mkAt = undefined;
		racers[i].mkRel = 0;
		racers[i].mkSlot = i;
		racers[i].mkLined = undefined;
		racers[i] thread sr\minigames\_round::muster();
	}
	sr\minigames\_round::announce("mkw", "^3Mario Kart race: ^7" + level.mkRace.laps + " laps");

	// Each racer's spawn ends on the grid; the countdown waits until all stand there, a few seconds at most.
	for (i = 0; i < 50 && !lined(); i++)
		wait 0.1;
	wait 1;

	// What the keys do, in the small print as the countdown begins.
	racers = raceList();
	for (i = 0; i < racers.size; i++)
	{
		racers[i] iPrintLn("^3[{+attack}]^7 uses the item you hold, ^3[{+back}]^7 held leaves it behind");
		racers[i] iPrintLn("^3[{+breath_sprint}]^7 held through a turn charges a mini-turbo, let go to fire it");
	}
	for (count = 3; count > 0; count--)
	{
		sr\minigames\_round::announce("mkw", "^3" + count);
		sr\minigames\_round::sound("mkw", "mkw_count");
		wait 1;
	}
	sr\minigames\_round::announce("mkw", "^2GO!");
	sr\minigames\_round::sound("mkw", "mkw_go");

	level.mkRace.started = true;
	level.mkRace.time = getTime();
	racers = raceList();
	for (i = 0; i < racers.size; i++)
	{
		racers[i] freezeControls(false);
		racers[i] thread race();
	}
	level thread places();

	// Over when everyone is in, half a minute after the first, or three minutes after the start; the last
	// half minute of either is called.
	first = undefined;
	called = false;
	for (;;)
	{
		wait 0.5;
		racers = raceList();
		left = 0;
		for (i = 0; i < racers.size; i++)
		{
			if (!isDefined(racers[i].mkDone))
				left++;
		}
		if (level.mkRace.finished && !isDefined(first))
			first = getTime();
		if (!left || !racers.size || (isDefined(first) && getTime() - first > 30000))
			break;
		if (getTime() - level.mkRace.time > 180000)
		{
			sr\minigames\_round::announce("mkw", "^1Time's up");
			break;
		}
		if (!called && (isDefined(first) || getTime() - level.mkRace.time > 150000))
		{
			called = true;
			sr\minigames\_round::announce("mkw", "^330 seconds left!");
		}
	}
	wait 1;
	// Stopping ends this thread, so it is left to another.
	level thread stop();
}

raceList()
{
	racers = [];
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		if (isDefined(players[i].mkRacing))
			racers[racers.size] = players[i];
	}
	return racers;
}

// Two abreast behind where the map starts its runs, each row a stride back.
grid(index)
{
	self endon("disconnect");

	// From the map's own start, not from wherever the racer has run to since spawning there.
	from = self.origin;
	yaw = self getPlayerAngles()[1];
	if (isDefined(level.spawn["player"]))
	{
		from = level.spawn["player"].origin;
		if (isDefined(level.spawn["player"].angles))
			yaw = level.spawn["player"].angles[1];
	}
	forward = anglesToForward((0, yaw, 0));
	right = anglesToRight((0, yaw, 0));
	side = -55;
	if (index % 2)
		side = 55;
	spot = from - forward * (120 * int(index / 2)) + right * side;

	trace = bulletTrace(spot + (0, 0, 80), spot - (0, 0, 400), false, self);
	if (trace["fraction"] < 1)
		spot = trace["position"] + (0, 0, 4);
	self setOrigin(spot);
	self setPlayerAngles((0, yaw, 0));
	self setVelocity((0, 0, 0));
	self freezeControls(true);
	self.mkSafe = spawnStruct();
	self.mkSafe.origin = spot;
	self.mkSafe.yaw = yaw;
	self.mkLined = true;
}

// Whether every racer stands on the grid.
lined()
{
	racers = raceList();
	for (i = 0; i < racers.size; i++)
	{
		if (!isDefined(racers[i].mkLined))
			return false;
	}
	return true;
}

// Before the start a spawn ends on the grid, still at once: there is no running about first and no
// second move. In the race it ends on the road where the last gate was passed, the lap kept.
onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (!self racing() || isDefined(self.mkDone))
		return;

	if (!level.mkRace.started)
	{
		self waittill("speedrun");
		self freezeControls(true);
		wait 0.05;
		self sr\minigames\_mkw_items::lose();
		self grid(IfUndef(self.mkSlot, 0));
		return;
	}
	if (!isDefined(self.mkSafe))
		return;

	self waittill("speedrun");
	wait 0.05;
	self setOrigin(self.mkSafe.origin);
	self setPlayerAngles((0, self.mkSafe.yaw, 0));
	self.iz_gate = self.mkGate;
	self thread race();
}

race()
{
	self endon("disconnect");
	self endon("death");
	self endon("spawned");
	level endon("mk_race_stop");

	self raceHud();
	for (;;)
	{
		wait 0.1;
		if (isDefined(self.mkDone))
			return;

		// The course's own gates say how far round the lap is.
		if (level.mkRace.gates && isDefined(self.iz_gate) && self.iz_gate != self.mkGate && self.iz_gate > 0)
		{
			self.mkGate = self.iz_gate;
			self.mkSafe.origin = self.origin;
			self.mkSafe.yaw = self getPlayerAngles()[1];
		}
		self.mkLapHud setText("^3LAP " + self.mkLap + "/" + level.mkRace.laps);
		if (isDefined(self.mkRank) && (!isDefined(self.mkPlaced) || self.mkPlaced != self.mkRank))
		{
			self.mkPlaced = self.mkRank;
			self.mkPlaceHud setText(sr\minigames\_race::getPlacementString(self.mkRank));
		}
	}
}

raceHud()
{
	self clean();
	self.mkLapHud = addHud(self, -96, 12, 1, "right", "top", 2.4, 5);
	self.mkLapHud setText("");
	// The place, low on the left and large, where the game shows it.
	self.mkPlaceHud = addHud(self, 28, -44, 1, "left", "bottom", 4, 100, true);
	self.mkPlaceHud.font = "objective";
	self.mkPlaceHud setText("");
	self.mkPlaced = undefined;
}

clean()
{
	if (isDefined(self.mkLapHud))
		self.mkLapHud destroy();
	if (isDefined(self.mkPlaceHud))
		self.mkPlaceHud destroy();
	self.mkLapHud = undefined;
	self.mkPlaceHud = undefined;
}

// A run's end is a lap's end while a race is on: the course calls it once every gate has been passed.
lap()
{
	if (!level.mkRace.started || isDefined(self.mkDone))
		return;

	self.mkLap++;
	self.mkGate = 0;
	self.mkRel = 0;
	if (self.mkLap <= level.mkRace.laps)
	{
		self playLocalSound("mkw_lap");
		if (self.mkLap == level.mkRace.laps)
			self iPrintLnBold("^3Final lap!");
		return;
	}
	self.mkLap = level.mkRace.laps;
	level.mkRace.finished++;
	self.mkDone = level.mkRace.finished;
	self.mkRank = self.mkDone;
	if (isDefined(self.mkPlaceHud))
		self.mkPlaceHud setText(sr\minigames\_race::getPlacementString(self.mkRank));

	time = (getTime() - level.mkRace.time) / 1000;
	iPrintLnBold("^3" + self.mkDone + ". ^7" + self.name + " ^3" + time + "s");
	self playLocalSound("mkw_goal");
	self freezeControls(true);
}

// Who leads, as the game tells it: by laps, then by how far round the lap each racer is along the course's
// own line. A map without one falls back on its gates and how near the next is.
places()
{
	level endon("mk_race_stop");

	gates = getEntArray("iz_gate", "targetname");
	finish = getEntArray("iz_finish", "targetname");
	line = 0;
	if (level.mkRoute.size > 3 && finish.size)
	{
		// The line's trigger stands far taller than the road: its height is the grid's.
		spot = finish[0] getOrigin();
		if (isDefined(level.spawn["player"]))
			spot = (spot[0], spot[1], level.spawn["player"].origin[2]);
		on = sr\minigames\_mkw_items::routeOn(spot);
		line = on[0] + on[1];
	}

	for (;;)
	{
		wait 0.1;
		racers = raceList();
		for (i = 0; i < racers.size; i++)
		{
			racer = racers[i];
			if (isDefined(racer.mkDone))
			{
				racer.mkProgress = 100000000 - racer.mkDone;
				continue;
			}
			if (level.mkRoute.size > 3)
			{
				racer.mkProgress = racer.mkLap * (level.mkRoute.size + 1) + racer along(line);
				continue;
			}
			next = undefined;
			for (g = 0; g < gates.size; g++)
			{
				if (gates[g].iz_order == racer.mkGate + 1)
					next = gates[g];
			}
			if (!isDefined(next) && finish.size)
				next = finish[0];
			to = 0;
			if (isDefined(next))
				to = distance(next getOrigin(), racer.origin);
			racer.mkProgress = racer.mkLap * 1000 + racer.mkGate - to / 100000;
		}
		for (i = 0; i < racers.size; i++)
		{
			if (isDefined(racers[i].mkDone))
				continue;
			rank = 1;
			for (j = 0; j < racers.size; j++)
			{
				if (racers[j].mkProgress > racers[i].mkProgress)
					rank++;
			}
			// A place won or lost is heard, once the grid has sorted itself out.
			if (isDefined(racers[i].mkRank) && rank != racers[i].mkRank && getTime() - level.mkRace.time > 5000)
			{
				if (rank < racers[i].mkRank)
					racers[i] playLocalSound("mkw_rank_up");
				else
					racers[i] playLocalSound("mkw_rank_down");
			}
			racers[i].mkRank = rank;
		}
	}
}

// How far round the lap a racer is, in stretches of the line counted from the finish. The search stays by
// where the racer last was, so a road that passes close to itself does not take them across; well off it,
// after a cannon or a fall, another road counts once it is clearly the nearer. Behind the line at the
// start the count is under zero, and over it again before the lap is counted it waits at the lap's end.
along(line)
{
	count = level.mkRoute.size;
	if (!isDefined(self.mkAt))
		self.mkAt = int(sr\minigames\_mkw_items::routeOn(self.origin)[0]);

	best = self.mkAt;
	share = 0;
	least = undefined;
	for (k = -2; k <= 5; k++)
	{
		i = (self.mkAt + k + count) % count;
		at = sr\minigames\_mkw_items::stretch(self.origin, i);
		if (!isDefined(least) || at[0] < least)
		{
			least = at[0];
			best = i;
			share = at[1];
		}
	}
	if (least > 300 * 300)
	{
		on = sr\minigames\_mkw_items::routeOn(self.origin);
		if (on[2] < least * 0.36)
		{
			best = int(on[0]);
			share = on[1];
		}
	}
	self.mkAt = best;

	rel = best + share - line;
	if (rel < 0)
		rel += count;
	if (rel >= count)
		rel -= count;

	if (rel - self.mkRel > count / 2)
		return rel - count;
	if (self.mkRel - rel > count / 2)
		return count;
	self.mkRel = rel;
	return rel;
}

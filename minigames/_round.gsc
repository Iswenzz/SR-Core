#include sr\sys\_events;
#include sr\utils\_common;

// A minigame played in rounds. Whoever asks for it waits in a lobby, playing as they like; the round then
// starts for all of them at once, and whoever asks while one runs watches it until the next, which follows
// at once for as long as anyone is left.
create(name, label, play)
{
	mini = level.minigames[name];
	mini.label = label;
	mini.play = play;
	mini.state = "idle";
	mini.lobby = 10;
	level thread rounds(name);
}

rounds(name)
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");

	mini = level.minigames[name];
	again = false;
	for (;;)
	{
		mini.state = "idle";
		wait 1;
		if (!mini.queue.size)
		{
			again = false;
			continue;
		}

		// The lobby's wait is for a first round: after one, the next round's own countdown is the wait.
		mini.state = "lobby";
		for (left = mini.lobby; !again && left > 0 && mini.queue.size && !isDefined(mini.now); left--)
		{
			if (left == mini.lobby || left <= 3)
				announce(name, mini.label + " ^7starts in ^3" + left);
			wait 1;
		}
		mini.now = undefined;
		if (!mini.queue.size)
			continue;

		mini.state = "running";
		[[mini.play]]();
		mini.state = "over";
		again = true;
	}
}

running(name)
{
	return isDefined(level.minigames[name].state) && level.minigames[name].state == "running";
}

// The next round without the lobby's wait.
now(name)
{
	level.minigames[name].now = true;
}

announce(name, text)
{
	players = level.minigames[name].queue;
	for (i = 0; i < players.size; i++)
	{
		if (isDefined(players[i]))
			players[i] iPrintLnBold(text);
	}
}

sound(name, alias)
{
	players = level.minigames[name].queue;
	for (i = 0; i < players.size; i++)
	{
		if (isDefined(players[i]))
			players[i] playLocalSound(alias);
	}
}

// Three, two, one, for everyone in it.
countdown(name)
{
	for (count = 3; count > 0; count--)
	{
		announce(name, "^3" + count);
		sound(name, "ui_mp_timer_countdown");
		wait 1;
	}
	announce(name, "^2GO!");
	sound(name, "mp_ingame_summary");
}

// Out of the round, or come while one runs: watching until the next.
watch()
{
	self endon("disconnect");

	// From over where the map starts its runs, not from the middle of nowhere.
	if (isDefined(level.spawn["player"]))
	{
		self.spectatorSpawn = spawnStruct();
		self.spectatorSpawn.origin = level.spawn["player"].origin + (0, 0, 80);
		self.spectatorSpawn.angles = (0, 0, 0);
	}
	self sr\core\_teams::setSpectator();
}

// Among the players again, if watching.
back()
{
	self endon("disconnect");

	if (self.pers["team"] != "spectator")
		return;
	self.spectatorSpawn = undefined;
	self sr\core\_teams::setTeam("allies");
	self eventSpawn(true);
}

// At the map's start for a round, whether watching or playing until now.
muster()
{
	self endon("disconnect");

	self sr\core\_teams::setTeam("allies");
	self eventSpawn(true);
}

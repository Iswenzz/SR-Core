getClientDvar(dvar)
{
	self endon("disconnect");

	self clientCmd(fmt("setu %s 0", dvar));
	value = self getuserinfo(dvar);
	return value;
}

getAllPlayers()
{
	return getEntArray("player", "classname");
}

getPlayerByNum(pNum)
{
	found = [];
	players = getAllPlayers();

	for (i = 0; i < players.size; i++)
	{
		if (players[i] getEntityNumber() == IfUndef(ToInt(pNum), -1))
			found[found.size] = players[i];
	}
	return found;
}

getPlayerByName(nickname)
{
	found = [];
	players = getAllPlayers();

	for (i = 0; i < players.size; i++)
	{
		if (isSubStr(toLower(players[i].name), toLower(nickname)))
			found[found.size] = players[i];
	}
	return found;
}

getPlayerVelocity()
{
	velocity = self getVelocity();
	return int(sqrt((velocity[0] * velocity[0]) + (velocity[1] * velocity[1])));
}

getPlayingPlayers()
{
	players = getAllPlayers();
	array = [];
	for (i = 0; i < players.size; i++)
	{
		if (players[i] isReallyAlive() && players[i].pers["team"] != "spectator")
			array[array.size] = players[i];
	}
	return array;
}

playSoundOnPosition(soundAlias, pos, local)
{
	soundObj = spawn("script_model", pos);
	if (isDefined(local) && local)
		soundObj playSoundToPlayer(soundAlias, self);
	soundObj playSound(soundAlias);
	soundObj delete();
}

playLoopSoundToPlayer(soundAlias, length)
{
	self endon("death");
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("spawned");

	while (true)
	{
		self playlocalsound(soundAlias);
		wait length;
	}
}

playLocalSoundLoop(soundAlias, length)
{
	self endon("death");
	self endon("disconnect");

	self notify("stoplocalsoundloop_" + soundAlias);
	self endon("stoplocalsoundloop_" + soundAlias);

	while (true)
	{
		self playlocalsound(soundAlias);
		wait length;
	}
}

playLoopSound(soundAlias, length)
{
	self notify("stopsoundloop_" + soundAlias);
	self endon("stopsoundloop_" + soundAlias);

	while (true)
	{
		if (!isDefined(self))
			return;
		self playsound(soundAlias);
		wait length;
	}
}

playSoundOnAllPlayers(soundAlias)
{
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		players[i] playLocalSound(soundAlias);
}

bounce(origin, power)
{
	self endon("disconnect");

	previousHealth = self.health;
	self.health = self.health + power;

	self setClientDvars(
		"bg_viewKickMax", 0,
		"bg_viewKickMin", 0,
		"bg_viewKickRandom", 0,
		"bg_viewKickScale", 0
	);
	self finishPlayerDamage(self, self, power, 0, "MOD_PROJECTILE",
		"none", undefined, origin, "none", 0);
	self.health = previousHealth;
	wait .05;

	self setClientDvars(
		"bg_viewKickMax", 90,
		"bg_viewKickMin", 5,
		"bg_viewKickRandom", 0.4,
		"bg_viewKickScale", 0.2
	);
}

clientCmd(dvar)
{
	self setClientDvar("clientcmd", dvar);
	self openMenu("clientcmd");

	if (isDefined(self))
		self closeMenu("clientcmd");
}

originToTime(origin)
{
	time = SpawnStruct();

	time.origin = origin;
	time.milsec = origin;
	time.min = int(time.milsec / 60000);
	time.milsec = time.milsec % 60000;
	time.sec = int(time.milsec / 1000);
	time.milsec = time.milsec % 1000;

	return time;
}

isInArray(array)
{
	for (i = 0; i < array.size; i++)
	{
		if (self == array[i])
			return true;
	}
	return false;
}

removeFromArray(array)
{
	new = [];
	for (i = 0; i < array.size; i++)
	{
		if (array[i] == self)
			continue;
		new[new.size] = array[i];
	}
	return new;
}

isReallyAlive()
{
	if (self.sessionstate == "playing")
		return true;
	return false;
}

isPlaying()
{
	return isReallyAlive();
}

waittill_any(a, b, c, d, e)
{
	if (isDefined(b))
		self endon(b);
	if (isDefined(c))
		self endon(c);
	if (isDefined(d))
		self endon(d);
	if (isDefined(e))
		self endon(e);
	self waittill(a);
}

randomColor()
{
	return (randomint(100) / 100, randomint(100) / 100, randomint(100) / 100);
}

randomColorDark()
{
	return (randomint(50) / 100, randomint(50) / 100, randomint(50) / 100);
}

cleanScreen()
{
	for (i = 0; i < 6; i++)
	{
		iPrintlnBold(" ");
		iPrintln(" ");
	}
}

spawnCollision(origin, height, width)
{
	level.colliders[level.colliders.size] = spawn("trigger_radius", origin, 0, width, height);
	level.colliders[level.colliders.size - 1] setContents(1);
	level.colliders[level.colliders.size - 1].targetname = "script_collision";
}

deleteAfterTime(time)
{
	wait time;
	if (isDefined(self))
		self delete();
}

// Trace allowing object arrays to be ignored
traceArray(start, end, hit_players, ignore_array)
{
	if (!isDefined(ignore_array))
		ignore_ent = undefined;
	else
		ignore_ent = ignore_array[0];

	if (!isDefined(hit_players))
		hit_players = false;

	trace = bullettrace(start, end, hit_players, ignore_ent);

	if (isDefined(ignore_array))
	{
		if (isDefined(trace["entity"]))
		{
			if (trace["entity"] isInArray(ignore_array))
				return traceArrayRaw(trace["position"], end, hit_players, ignore_array, trace["entity"], trace["fraction"]);
		}
	}
	return trace;
}

// Trace allowing object arrays to be ignored
traceArrayRaw(start, end, hit_players, ignore_array, ignore_ent, fraction_add)
{
	// Fraction needs to be corrected
	trace = bullettrace(start, end, hit_players, ignore_ent);
	trace["fraction"] = fraction_add + (1 - fraction_add) * trace["fraction"];

	if (isDefined(trace["entity"]))
	{
		if (trace["entity"] isInArray(ignore_array))
			return traceArrayRaw(trace["position"], end, hit_players, ignore_array, trace["entity"], trace["fraction"]);
	}
	return trace;
}

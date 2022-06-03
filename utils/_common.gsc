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

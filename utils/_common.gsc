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
	if (!isDefined(pNum))
		return undefined;

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		if (players[i] getEntityNumber() == IfUndef(ToInt(pNum), -1))
			return players[i];
	}
	return undefined;
}

getPlayerByName(nickname)
{
	if (!isDefined(nickname))
		return undefined;

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		if (isSubStr(toLower(players[i].name), toLower(nickname)))
			return players[i];
	}
	return undefined;
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

getFPS()
{
	fps = self getUserInfo("com_maxfps");

	if (IsNullOrEmpty(fps))
		return 125;
	return ToInt(fps);
}

canSpawn()
{
	if (game["state"] == "endmap" || game["state"] == "round ended")
		return false;
	if (self.sessionstate == "playing" && self.died)
		return false;
	if (level.freeRun)
		return true;
	if (!level.allowSpawn)
		return false;
	return true;
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

bounce(origin, direction, power)
{
	self endon("disconnect");
	self endon("death");

	previousMaxHealth = self.maxhealth;
	previousHealth = self.health;

	self.maxhealth = self.maxhealth + power;
	self.health = self.health + power;

	self setClientDvars(
		"bg_viewKickMax", 0,
		"bg_viewKickMin", 0,
		"bg_viewKickRandom", 0,
		"bg_viewKickScale", 0
	);
	self finishPlayerDamage(self, self, power, 0, "MOD_PROJECTILE", "none", origin, direction, "none", 0);
	self.maxhealth = previousMaxHealth;
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
	if (!isDefined(dvar))
		return;

	self setClientDvar("clientcmd", dvar);
	self openMenu("clientcmd");

	if (isDefined(self))
		self closeMenu("clientcmd");
}

originToTime(origin)
{
	time = SpawnStruct();

	time.origin = origin;
	time.ms = origin;
	time.min = int(time.ms / 60000);
	time.ms = time.ms % 60000;
	time.sec = int(time.ms / 1000);
	time.ms = time.ms % 1000;

	return time;
}

foreachThread(array, callback, args)
{
	for (i = 0; i < array.size; i++)
		Ternary(isDefined(args), array[i] thread [[callback]](args), array[i] thread [[callback]]());
}

foreachCall(array, callback, args)
{
	for (i = 0; i < array.size; i++)
		Ternary(isDefined(args), array[i] [[callback]](args), array[i] [[callback]]());
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

waitTillNotMoving()
{
	prevorigin = self.origin;
	while (isDefined(self))
	{
		wait .15;
		if (self.origin == prevorigin)
			break;
		prevorigin = self.origin;
	}
}

randomColor()
{
	return (randomint(100) / 100, randomint(100) / 100, randomint(100) / 100);
}

randomColorDark()
{
	return (randomint(50) / 100, randomint(50) / 100, randomint(50) / 100);
}

intRange(variable, min, max)
{
	variable++;
	if (variable < min)
		return max;
	if (variable > max)
		return min;
	return variable;
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

reconnect()
{
	self clientCmd("reconnect");
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

triggerOff()
{
	if (!isDefined(self.realOrigin))
		self.realOrigin = self.origin;
	if (self.origin == self.realorigin)
		self.origin += (0, 0, -10000);
}

triggerOn()
{
	if (isDefined(self.realOrigin))
		self.origin = self.realOrigin;
}

setLowerMessage(text, time)
{
	if (!isDefined(self.lowerMessage))
		return;

	if (isDefined(self.lowerMessageOverride) && text != &"")
	{
		text = self.lowerMessageOverride;
		time = undefined;
	}

	self notify("lower_message_set");
	self.lowerMessage setText(text);
	if (isDefined(time) && time > 0)
		self.lowerTimer setTimer(time);
	self.lowerMessage fadeOverTime(0.05);
	self.lowerMessage.alpha = 1;
	self.lowerTimer fadeOverTime(0.05);
	self.lowerTimer.alpha = 1;
}

clearLowerMessage(fadetime)
{
	if (!isDefined(self.lowerMessage))
		return;

	self notify("lower_message_set");

	if (!isDefined(fadetime) || fadetime == 0)
	{
		setLowerMessage(&"");
		return;
	}

	self endon("disconnect");
	self endon("lower_message_set");

	self.lowerMessage fadeOverTime(fadetime);
	self.lowerMessage.alpha = 0;
	self.lowerTimer fadeOverTime(fadetime);
	self.lowerTimer.alpha = 0;

	wait fadetime;

	self setLowerMessage("");
}

cleanUp()
{
	self setClientDvar("cg_thirdperson", 0);
	self setClientDvar("cg_thirdpersonrange", 80);
	self setClientDvar("r_blur", 0);
	self setClientDvar("ui_healthbar", 1);
	self setClientDvar("bg_viewKickMax", 90);
	self setClientDvar("bg_viewKickMin", 5);
	self setClientDvar("bg_viewKickRandom", 0.4);
	self setClientDvar("bg_viewKickScale", 0.2);

	self clearLowerMessage();
	self unLink();
	self enableWeapons();
}

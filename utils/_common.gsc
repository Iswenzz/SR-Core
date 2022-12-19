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
	if (isDefined(self.demo))
		return self getSpeedrunVelocity();

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
	return self getCountedFPS();
}

setu(var, value)
{
	self clientCmd(fmt("setu %s %s", var, value));
	wait 0.05;
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

isNewRun(run)
{
	return ToString(self.run) != ToString(run);
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

bounce(origin, direction, power, repeat, useDvars)
{
	self endon("disconnect");
	self endon("death");

	repeat = IfUndef(repeat, 1);
	if (isDefined(self.sr_mode) && self.sr_mode == "Defrag")
		useDvars = false;

	if (!isDefined(useDvars))
	{
		self setClientDvars(
			"bg_viewKickMax", 0,
			"bg_viewKickMin", 0,
			"bg_viewKickRandom", 0,
			"bg_viewKickScale", 0
		);
	}

	for (i = 0; i < repeat; i++)
	{
		previousMaxHealth = self.maxhealth;
		previousHealth = self.health;

		self.maxhealth = self.maxhealth + power;
		self.health = self.health + power;

		self finishPlayerDamage(self, self, power, 0, "MOD_PROJECTILE", "none", origin, direction, "none", 0);
		self.maxhealth = previousMaxHealth;
		self.health = previousHealth;
	}

	if (!isDefined(useDvars))
	{
		wait .05;
		self setClientDvars(
			"bg_viewKickMax", 90,
			"bg_viewKickMin", 5,
			"bg_viewKickRandom", 0.4,
			"bg_viewKickScale", 0.2
		);
	}
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

pickRandom(array, amount)
{
	randoms = [];

	if (array.size < amount)
		return randoms;
	if (amount == 1)
		return array;

	while (randoms.size < amount)
	{
		picked = array[randomIntRange(0, array.size)];
		if (Contains(randoms, picked))
			continue;
		randoms[randoms.size] = picked;
	}
	return randoms;
}

foreachThread(array, callback, args)
{
	for (i = 0; i < array.size; i++)
	{
		if (isDefined(args))
			array[i] thread [[callback]](args);
		else
			array[i] thread [[callback]]();
	}
}

foreachCall(array, callback, args)
{
	for (i = 0; i < array.size; i++)
	{
		if (isDefined(args))
			array[i] [[callback]](args);
		else
			array[i] [[callback]]();
	}
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
	return isDefined(self) && isDefined(self.sessionstate) && self.sessionstate == "playing";
}

isPlaying()
{
	return self isReallyAlive();
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
			if (Contains(ignore_array, trace["entity"]))
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
		if (Contains(ignore_array, trace["entity"]))
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

waitMapLoad(extraTime)
{
	time = IfUndef(extraTime, 0) + 3;
	wait time; // Spastic map loading
}

cleanUp()
{
	self clearLowerMessage();
	self unLink();
	self enableWeapons();
}

spawnBots(number)
{
	bots = [];
	for (i = 0; i < number; i++)
	{
		bot = addTestClient();
		wait 0.05;
		bot notify("menuresponse", game["menu_main"], "autoassign");
		bots[bots.size] = bot;
	}
	return bots;
}

getHitLocHeight(sHitLoc)
{
	switch (sHitLoc)
	{
		case "helmet":
		case "object":
		case "neck":
			return 60;

		case "torso_upper":
		case "right_arm_upper":
		case "left_arm_upper":
		case "right_arm_lower":
		case "left_arm_lower":
		case "right_hand":
		case "left_hand":
		case "gun":
			return 48;

		case "torso_lower":
			return 40;

		case "right_leg_upper":
		case "left_leg_upper":
			return 32;

		case "right_leg_lower":
		case "left_leg_lower":
			return 10;

		case "right_foot":
		case "left_foot":
			return 5;
	}
	return 48;
}

ragdoll(sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath, deathAnimDuration)
{
	self endon("disconnect");

	body = self clonePlayer(deathAnimDuration);
	body setContents(0);
	body hide();
	body.targetname = "ragdoll";

	if (!isDefined(body))
		return;

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		if (players[i].settings["gfx_ragdoll"])
			body showToPlayer(players[i]);
	}
	if (isDefined(body))
	{
		if (self isOnLadder() || self isMantling())
			body startRagdoll();

		deathAnim = body getCorpseAnim();
		if (animHasNotetrack(deathAnim, "ignore_ragdoll"))
			return;
	}
	wait 0.2;

	if (!isDefined(vDir))
		vDir = (0, 0, 0);

	explosionPos = body.origin + (0, 0, getHitLocHeight(sHitLoc));
	explosionPos -= vDir * 20;
	explosionRadius = 40;
	explosionForce = .75;

	if (sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_EXPLOSIVE" ||
		isSubStr(sMeansOfDeath, "MOD_GRENADE") || isSubStr(sMeansOfDeath, "MOD_PROJECTILE") ||
		sHitLoc == "object" || sHitLoc == "helmet")
		explosionForce = 2.9;

	body startRagdoll(1);

	wait 0.05;

	if (!isDefined(body))
		return;

	physicsExplosionSphere(explosionPos, explosionRadius, explosionRadius / 2, explosionForce);
}

getFloor()
{
	if (isDefined(self.inAir) && self.inAir)
		return self.origin[2] + ifUndef(self.inAirValue, 0);

	trace = BulletTrace(self.origin, self.origin - (0, 0, 999999), false, undefined);
	return Ternary(trace["fraction"] != 1, trace["position"], self.origin)[2];
}

rectanglePoints()
{
	size = [];
	tag = spawn("script_origin", self.origin);
	ori1 = tag getOrigin();
	x = 0;

	// Rectangle Size
	while (tag isTouching(self))
	{
		tag.origin = (tag.origin + (x, 0, 0));
		wait 0.05;
		x++;
	}
	ori2 = tag getOrigin();
	x = ori2[0] - ori1[0];
	size[size.size] = x;

	tag.origin = self.origin - (0, 0, 0);
	ori1 = tag getOrigin();
	y = 0;
	while (tag isTouching(self))
	{
		tag.origin = (tag.origin + (0, y, 0));
		wait 0.05;
		y++;
	}
	ori2 = tag getOrigin();
	y = ori2[1] - ori1[1];

	size[size.size] = y;
	tag.origin = self.origin - (0, 0, 0);
    ori1 = tag getOrigin();
    z = 0;
    while (tag isTouching(self))
    {
        tag.origin = (tag.origin + (0, 0, z));
        wait 0.05;
        z--;
    }
    ori2 = tag getOrigin();
    z = ori2[2] - ori1[2];

    size[size.size] = z;
	tag delete();

	// Rectangle points
	points = [];
	width = size[0];
	length = size[1];
	heightBottom = size[2];

	z = self getFloor();
	if (isDefined(self.inAir) && self.inAir)
		z += heightBottom;

	x = self.origin[0] + width;
	y = self.origin[1] + length;
	points[points.size] = (x, y, z);
	x = self.origin[0] + width;
	y = self.origin[1] - length;
	points[points.size] = (x, y, z);
	x = self.origin[0] - width;
	y = self.origin[1] - length;
	points[points.size] = (x, y, z);
	x = self.origin[0] - width;
	y = self.origin[1] + length;
	points[points.size] = (x, y, z);

	return points;
}

circlePoints()
{
	points = [];
	idx = 0;

	r = IfUndef(self.radius, 0);
	z = self getFloor();
	h = self.origin[0];
	k = self.origin[1];

	for (i = 0; i < 360; i++)
	{
		x = h + r * cos(i);
		y = k - r * sin(i);

		points[idx] = (x, y, z);

		if (i % 2 == 0)
			idx++;
	}
	return points;
}

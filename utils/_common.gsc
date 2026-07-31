#include sr\utils\_math;
#include sr\sys\_events;

getClientDvar(dvar)
{
	self endon("disconnect");

	self clientCmd(fmt("setu temp null; setfromdvar temp %s; setu %s null; setfromdvar %s temp", dvar, dvar, dvar));
	return self getUserInfo(dvar);
}

getAllPlayers()
{
	return getEntArray("player", "classname");
}

getPlayerById(id)
{
	if (!isDefined(id))
		return undefined;

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		if (players[i].id == id)
			return players[i];
	}
	return undefined;
}

getPlayerByNum(pNum)
{
	if (!isDefined(pNum))
		return undefined;

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		if (players[i].number == IfUndef(ToInt(pNum), -1))
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
	if (self isDemo())
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
		if (players[i] isPlaying() && !players[i] isDead())
			array[array.size] = players[i];
	}
	return array;
}

getAlliesPlayers()
{
	players = getAllPlayers();
	array = [];
	for (i = 0; i < players.size; i++)
	{
		if (players[i] isAllies())
			array[array.size] = players[i];
	}
	return array;
}

getDeadPlayers()
{
	players = getAllPlayers();
	array = [];
	for (i = 0; i < players.size; i++)
	{
		if (!players[i] isPlaying() && players[i] isDead())
			array[array.size] = players[i];
	}
	return array;
}

getFPS()
{
	return self getCountedFPS();
}

getPlayerFPS()
{
	fps = self getFPS();

	if (fps <= 10) 		return 0;
	if (fps <= 60) 		return 20;
	if (fps <= 125) 	return 125;
	if (fps <= 142) 	return 142;
	if (fps <= 166) 	return 166;
	if (fps <= 200) 	return 200;
	if (fps <= 250) 	return 250;
	if (fps <= 333) 	return 333;
	if (fps <= 500) 	return 500;
	if (fps <= 1000) 	return 1000;

	return 0;
}

respawn()
{
	if (game["state"] == "end" || game["state"] == "round ended")
		return;

	self.died = false;
	self.cheating = true;
	eventSpawn(true);
}

canSpawn()
{
	if (!level.allowSpawn)
		return false;
	if (game["state"] == "end" || game["state"] == "round ended")
		return false;
	if (self isPlaying())
		return false;
	if (isDefined(level.freeRun) && level.freeRun)
		return true;
	if (self isDead() && !self.pers["lifes"])
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
	self endon("spectator");
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

playerButton(id)
{
	return buttonFlags(self getDemoButtons(), id);
}

demoButton(id)
{
	return buttonFlags(self getDemoButtons(), id);
}

buttonFlags(buttons, id)
{
	switch (id)
	{
		case "fire":			return buttons & 1;
		case "sprint":			return buttons & 2;
		case "melee":			return buttons & 4;
		case "use":				return buttons & 8;
		case "usereload":		return buttons & 32;
		case "reload":			return buttons & 16;
		case "leanleft":		return buttons & 64;
		case "leanright":		return buttons & 128;
		case "prone":			return buttons & 256;
		case "crouch":			return buttons & 512;
		case "jump":			return buttons & 1024;
		case "adsmode":			return buttons & 2048;
		case "tempaction":		return buttons & 4096;
		case "holdbreath":		return buttons & 8192;
		case "frag":			return buttons & 16384;
		case "smoke":			return buttons & 32768;
		case "nightvision":		return buttons & 262144;
		case "ads":				return buttons & 524288;
	}
	return false;
}

playSoundOnAllPlayers(soundAlias)
{
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		players[i] playLocalSound(soundAlias);
}
doRadiusDamage(position, range, power, knockback)
{
	if (!isDefined(self) || game["state"] == "end")
		return;

	players = getPlayingPlayers();
	for (i = 0; i < players.size; i++)
	{
		player = players[i];
		// Q3 style: distance to the closest point of the player's box, sphere radius
		dist = player bboxDistance(position);
		// Q3: dir = player center - explosion, +24 up (center is +35 on cod4 feet origin)
		direction = player.origin + (0, 0, 59) - position;
		modifier = 1 - dist / (range * 1.0);
		damage = int(power * modifier);
		kb = int(knockback * modifier);

		if (dist > range || damage < 1)
			continue;
		if (!splashVisible(position, player))
			continue;

		// Q3: half damage when hurting self, knockback stays full
		if (player == self)
			damage = int(damage * 0.5);

		player eventDamage(self, self, damage, 0, "MOD_PROJECTILE", "none", position, direction, "none", 0);

		if (kb < 1)
			continue;
		if (self sameTeam(player) && !self.teamKill)
			continue;
		if (self == player)
			continue;

		player cheat();
		player bounce(position, direction, kb);
	}
}

collidePlayerRange(position, range)
{
	return self bboxDistance(position) <= range;
}

bboxDistance(position)
{
	return bboxDistanceAt(self.origin, position);
}

bboxDistanceAt(origin, position)
{
	dx = axisDistance(position[0], origin[0] - 15, origin[0] + 15);
	dy = axisDistance(position[1], origin[1] - 15, origin[1] + 15);
	dz = axisDistance(position[2], origin[2], origin[2] + 70);

	return length((dx, dy, dz));
}

axisDistance(p, min, max)
{
	if (p < min)
		return min - p;
	if (p > max)
		return p - max;
	return 0;
}

splashVisible(position, player)
{
	center = player.origin + (0, 0, 35);

	if (traceClear(position, center))
		return true;
	if (traceClear(position, center + (15, 15, 0)))
		return true;
	if (traceClear(position, center + (15, -15, 0)))
		return true;
	if (traceClear(position, center + (-15, 15, 0)))
		return true;
	if (traceClear(position, center + (-15, -15, 0)))
		return true;
	return false;
}

traceClear(from, to)
{
	trace = bulletTrace(from, to, false, undefined);
	return trace["fraction"] == 1;
}

// Q3: velocity += dir * points * 5 (points == damage dealt, max 200)
// CoD4 engine: kb = min(60, int(power * stanceMod)); vel += dir * kb * g_knockback / 250
// Maxes out at 60 * g_knockback / 250 ups -> split into repeats
bounce(origin, direction, points)
{
	self endon("disconnect");
	self endon("death");

	if (points > 200)
		points = 200;
	if (points < 1)
		return;

	stanceMod = 0.3;
	stance = self getStance();
	if (stance == "crouch")
		stanceMod = 0.15;
	else if (stance == "prone")
		stanceMod = 0.02;

	scale = getDvarFloat("g_knockback") / 250;
	if (scale <= 0)
		return;

	ups = points * 5;
	maxUps = 60 * scale;
	repeat = int(ups / maxUps) + 1;

	kbPoints = (ups / repeat) / scale;
	power = int(kbPoints / stanceMod + 0.5);

	for (i = 0; i < repeat; i++)
	{
		previousMaxHealth = self.maxhealth;
		previousHealth = self.health;

		self.maxhealth = self.maxhealth + power;
		self.health = self.health + power;

		self doPlayerDamage(self, self, power, 0, "MOD_PROJECTILE", "none", origin, direction, "none", 0);
		self.maxhealth = previousMaxHealth;
		self.health = previousHealth;
	}
}

doPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if (!isDefined(self) || !self isPlaying() || self isDemo() || game["state"] == "end")
		return;

	self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
}

clientCmd(dvar)
{
	self endon("disconnect");

	if (!isDefined(self) || !isDefined(dvar))
		return;

	self setClientDvar("clientcmd", dvar);
	wait 0.05; // Wait 1 frame before opening the menu
	self openMenu("clientcmd");
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

removeFromArray(array, value)
{
	filters = [];
	for (i = 0; i < array.size; i++)
	{
		if (array[i] != value)
			filters[filters.size] = array[i];
	}
	return filters;
}

isPlaying()
{
	return isDefined(self) && self.sessionstate == "playing";
}

isDead()
{
	return isDefined(self) && (self.sessionstate == "dead" || self.died);
}

isSpectator()
{
	return isDefined(self) && self.sessionstate == "spectator";
}

isAllies()
{
	return isDefined(self) && self.pers["team"] == "allies";
}

isAxis()
{
	return isDefined(self) && self.pers["team"] == "axis";
}

isDemo()
{
	return isDefined(self) && isDefined(self.demo);
}

isBot()
{
	return isDefined(self) && self.isBot;
}

isQ3()
{
	if (isDefined(self.sr_mode) && (self.sr_mode == "Q3" || self.sr_mode == "Q3CPM" || self.sr_mode == "Q3CPMW"))
		return true;
	return false;
}

isCS()
{
	if (isDefined(self.sr_mode) && (self.sr_mode == "CS" || self.sr_mode == "Portal"))
		return true;
	return false;
}

isPortal()
{
	if (isDefined(self.sr_mode) && self.sr_mode == "Portal")
		return true;
	return false;
}

isCJ()
{
	return isDefined(level.map_cj) && level.map_cj;
}

isSlide()
{
	return isDefined(level.map_slide) && level.map_slide;
}

isSurf()
{
	return isDefined(level.map_surf) && level.map_surf;
}

waitSessionState(state)
{
	while (self.sessionstate != state)
		wait 0.05;
}

waittills(a, b, c, d, e)
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
	return (randomInt(100) / 100, randomInt(100) / 100, randomInt(100) / 100);
}

randomColorDark()
{
	return (randomInt(50) / 100, randomInt(50) / 100, randomInt(50) / 100);
}

addHealth(health)
{
	self.health += clampValue(self.health, health, 0, self.maxhealth);
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

clamp(number, min, max)
{
	if (number < min)
		return min;
	if (number > max)
		return max;
	return number;
}

clampValue(number, value, min, max)
{
	result = number + value;
	if (result < min)
		return min - number;
	if (result > max)
		return max - number;
	return result - number;
}

linearScale(value, min, max, rangeMin, rangeMax)
{
	return clamp((value - min) * (rangeMax - rangeMin) / (max - min) + rangeMin, rangeMin, rangeMax);
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
trace(start, end, hitPlayers, ignoreArray)
{
	ignoreEnt = undefined;
	if (isDefined(ignoreArray))
		ignoreEnt = ignoreArray[0];

	hitPlayers = IfUndef(hitPlayers, false);
	trace = bulletTrace(start, end, hitPlayers, ignoreEnt);

	if (isDefined(ignoreArray) && isDefined(trace["entity"]))
	{
		if (Contains(ignoreArray, trace["entity"]))
			return traceCorrection(trace["position"], end, hitPlayers, ignoreArray, trace["entity"], trace["fraction"]);
	}
	return trace;
}

traceCorrection(start, end, hitPlayers, ignoreArray, ignoreEnt, fraction)
{
	// Fraction needs to be corrected
	trace = bulletTrace(start, end, hitPlayers, ignoreEnt);
	trace["fraction"] = fraction + (1 - fraction) * trace["fraction"];

	if (isDefined(trace["entity"]))
	{
		if (Contains(ignoreArray, trace["entity"]))
			return traceCorrection(trace["position"], end, hitPlayers, ignoreArray, trace["entity"], trace["fraction"]);
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

playersSetLowerMessage(text, time)
{
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		players[i] setLowerMessage(text, time);
}

playersClearLowerMessage(fadetime)
{
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		players[i] clearLowerMessage(fadetime);
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

clearLowerMessageAfterTime(time)
{
	wait IfUndef(time, 3);
	self clearLowerMessage();
}

waitMapLoad(time)
{
	wait time;
}

isFirstConnection()
{
	return !isDefined(self.pers["connected"]);
}

setPersistence(name, value)
{
	self.pers[name] = value;
}

getPersistence(name, defaultValue)
{
	return IfUndef(self.pers[name], defaultValue);
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

spawnPlayer()
{
	spawn = spawnStruct();
	spawn.origin = (0, 0, 0);
	spawn.angles = (0, 0, 0);

	if (isDefined(self.minigameSpawn))
		spawn = self.minigameSpawn;
	else if (isDefined(self.playerSpawn))
		spawn = self.playerSpawn;
	else if (isDefined(self.insertionSpawn))
		spawn = self.insertionSpawn;
	else if (isDefined(level.spawn["player"]))
		spawn = level.spawn["player"];

	self spawn(spawn.origin, spawn.angles);
}

spawnSpectator()
{
	spawn = spawnStruct();
	spawn.origin = (0, 0, 0);
	spawn.angles = (0, 0, 0);

	if (isDefined(self.spectatorSpawn))
		spawn = self.spectatorSpawn;
	else if (isDefined(level.spawn["spectator"]))
		spawn = level.spawn["spectator"];

	self spawn(spawn.origin, spawn.angles);
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

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		if (players[i] sr\core\_settings::getPlayerSetting("gfx_ragdoll", true))
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

	if (!isDefined(body))
		return;

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

isWallbang(attacker, victim)
{
	start = attacker getEye();
	end = victim getEye();

	return !bulletTracePassed(start, end, false, attacker);
}

getFloor()
{
	if (isDefined(self.inAir) && self.inAir)
		return self.origin[2] + ifUndef(self.inAirValue, 0);

	trace = bulletTrace(self.origin, self.origin - (0, 0, 999999), false, undefined);
	return Ternary(trace["fraction"] != 1, trace["position"], self.origin)[2];
}

findClosestSurface(origin)
{
	directions = 8;
    fraction = 1;
	position = undefined;

    for (i = 0; i < directions; i++)
    {
        direction = angleToVector(i * (360 / directions));
        trace = bulletTrace(origin, origin + vectorScale(direction, 15), false, self);

        if (trace["fraction"] < fraction)
        {
            fraction = trace["fraction"];
            position = trace["position"];
        }
    }
    return position;
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

removeColorFromString(string)
{
	output = "";
	for (i = 0; i < string.size; i++)
	{
		if (string[i] == "^")
		{
			if (i < string.size - 1)
			{
				if (string[i + 1] == "0" || string[i + 1] == "1" || string[i + 1] == "2" || string[i + 1] == "3" || string[i + 1] == "4" || string[i + 1] == "5" || string[i + 1] == "6" || string[i + 1] == "7" || string[i + 1] == "8" || string[i + 1] == "9")
				{
					i++;
					continue;
				}
			}
		}
		output += string[i];
	}
	return output;
}

stringIndex(string, match)
{
	for (i = 0; i < string.size; i++)
	{
		if (getSubStr(string, i, i + match.size) == match)
			return i;
	}
	return -1;
}

stringChunk(string, maxchars)
{
	result = [];
	chunk = "";

	for (i = 0; i < string.size; i++)
	{
		chunk += string[i];
		if (chunk.size == maxchars)
		{
			result[result.size] = chunk;
			chunk = "";
		}
	}
	if (chunk.size > 0)
		result[result.size] = chunk;
	return result;
}

sameTeam(player)
{
	return self.pers["team"] == player.pers["team"];
}

printBold(msg)
{
	if (isPlayer(self))
		self iPrintLnBold(msg);
	else
		comPrintLn(msg);
}

printLine(msg)
{
	if (isPlayer(self))
		self iPrintLn(msg);
	else
		comPrintLn(msg);
}

message(msg)
{
	if (isPlayer(self))
		exec(fmt("say %s", msg));
	else
		comPrintLn(msg);
}

pm(msg)
{
	if (isPlayer(self))
		exec(fmt("tell %d %s", self.number, msg));
	else
		comPrintLn(msg);
}

confirmation()
{
	self notify("confirmation");
	wait 0.05;
	self endon("confirmation");
	self endon("disconnect");

	self waittill("confirmed");
	self pm("^2Confirmed.");
	return true;
}

hasConfirmed(confirmation)
{
	return isDefined(confirmation) && confirmation;
}

generateToken(digits)
{
    token = "" + randomIntRange(1, 10);
    for (i = 1; i < digits; i++)
        token += randomInt(10);
    return token;
}

cheat(state)
{
	if (!isDefined(state))
		state = true;
	self.sr_cheat = state;
}

isCheat()
{
	return isDefined(self.sr_cheat) && self.sr_cheat;
}

noop()
{

}

noopTrue()
{
	return true;
}

noopFalse()
{
	return false;
}

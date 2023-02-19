#include sr\utils\_math;
#include sr\sys\_events;

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
		if (players[i] isPlaying() && players[i].pers["team"] != "spectator")
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
		if (!players[i] isPlaying() && players[i].pers["team"] != "spectator")
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
	if (fps <= 20) 		return 20;
	if (fps <= 30) 		return 30;
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

setu(dvar)
{
	if (!isDefined(dvar) || self isBot())
		return;

	if (isDefined(self))
		self clientCmd(fmt("setfromdvar temp %s; setu %s null; setfromdvar %s temp", dvar, dvar, dvar));
}

respawn()
{
	if (game["state"] == "end" || game["state"] == "round ended")
		return;
	if (self.pers["team"] != "allies")
		return;

	self.died = false;
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
	if (level.freeRun)
		return true;
	if (self.died && !self.pers["lifes"])
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

bounce(origin, direction, power, repeat, useDvars)
{
	self endon("disconnect");
	self endon("death");

	repeat = IfUndef(repeat, 1);
	if (self isDefrag())
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

		self doPlayerDamage(self, self, power, 0, "MOD_PROJECTILE", "none", origin, direction, "none", 0);
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

doPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if (!isDefined(self) || self isDemo() || game["state"] == "end")
		return;

	self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
}

// Radius damage with knockback
// This function is used for defrag and any knockback runs
doRadiusDamage(position, range, power, knockback)
{
	if (!isDefined(self) || game["state"] == "end")
		return;

	players = getPlayingPlayers();
	for (i = 0; i < players.size; i++)
	{
		player = players[i];
		distance = int(distance(player.origin, position));
		distanceXY = int(distance2D(player.origin, position));
		direction = player eyePos() - position;
		modifier = 1 - (distanceXY / range);
		damage = int(power * modifier);
		multiplier = 2;

		if (!player collidePlayerRange(position, range))
			continue;

		player eventDamage(self, self, damage, 0, "MOD_PROJECTILE", "none", position, direction, "none", 0);

		if (distance > range || !knockback)
			continue;
		if (self sameTeam(player) && !self.teamKill)
			continue;
		if (self == player)
			continue;

		player cheat();
		player bounce(position, direction, knockback, multiplier);
	}
}

collidePlayerRange(position, range)
{
	distanceXY = int(distance2D(self.origin, position));
	distanceZ = int(abs(self.origin[2] - position[2]));

	return distanceXY <= range && distanceZ <= 70;
}

clientCmd(dvar)
{
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
	return isDefined(self) && self.sessionstate == "dead";
}

isSpectator()
{
	return isDefined(self) && self.sessionstate == "spectator";
}

isDemo()
{
	return isDefined(self) && isDefined(self.demo);
}

isBot()
{
	return isDefined(self) && self.isBot;
}

isDefrag()
{
	if (isDefined(self.sr_mode) && self.sr_mode == "Defrag")
		return true;
	if (self sr\player\modes\_main::isInMode("defrag"))
		return true;
	return false;
}

isPortal()
{
	if (isDefined(self.sr_mode) && self.sr_mode == "Portal")
		return true;
	if (self sr\player\modes\_main::isInMode("portal"))
		return true;
	return false;
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

isWallKnifing(attacker, victim)
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

getCustomizeWeapon()
{
	num = self getStat(981);
	if (self sr\game\_rank::isWeaponUnlocked(num))
		return level.assets["weapon"][num];
	return level.assets["weapon"][0];
}

getCustomizeCharacter()
{
	num = self getStat(980);
	if (self sr\game\_rank::isCharacterUnlocked(num))
		return level.assets["character"][num];
	return level.assets["character"][0];
}

getCustomizeKnife()
{
	num = self getStat(982);
	if (self sr\game\_rank::isKnifeUnlocked(num))
		return level.assets["knife"][num];
	return level.assets["knife"][0];
}

getCustomizeKnifeSkin()
{
	num = self getStat(983);
	if (self sr\game\_rank::isKnifeSkinUnlocked(num))
		return level.assets["knife_skin"][num];
	return level.assets["knife_skin"][0];
}

getCustomizeSpray()
{
	num = self getStat(979);
	if (self sr\game\_rank::isSprayUnlocked(num))
		return level.assets["spray"][num];
	return level.assets["spray"][0];
}

getCustomizeGlove()
{
	num = self getStat(985);
	if (self sr\game\_rank::isGloveUnlocked(num))
		return level.assets["glove"][num];
	return level.assets["glove"][0];
}

getCustomizeFx()
{
	num = self getStat(986);
	if (self sr\game\_rank::isFxUnlocked(num))
		return level.assets["fx"][num];
	return level.assets["fx"][0];
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
		exec(fmt("tell %d %s", self getEntityNumber(), msg));
	else
		comPrintLn(msg);
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

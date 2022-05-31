/*

  _|_|_|            _|      _|      _|                  _|
_|        _|    _|    _|  _|        _|          _|_|    _|  _|_|_|_|
  _|_|    _|    _|      _|          _|        _|    _|  _|      _|
      _|  _|    _|    _|  _|        _|        _|    _|  _|    _|
_|_|_|      _|_|_|  _|      _|      _|_|_|_|    _|_|    _|  _|_|_|_|

Script made by SuX Lolz (Iswenzz) and Sheep Wizard

Steam: http://steamcommunity.com/profiles/76561198163403316/
Discord: https://discord.gg/76aHfGF
Youtube: https://www.youtube.com/channel/UC1vxOXBzEF7W4g7TRU0C1rw
Paypal: suxlolz@outlook.fr
Email Pro: suxlolz1528@gmail.com

*/
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

#include sr\sys\_common;

init()
{
	level.racePoints = [];
	level.raceSpawn = level.masterspawn;
	level.raceEndTrig = getEnt("endmap_trig", "targetname");
	level.racePlayers = [];
	level.racePlayersFinished = [];
	level.raceScoreboard = [];
	level.placedPoints = [];
	level.raceStarted = false;
	level.raceCanJoin = true;

	level waittill("game started");
	loadAllPoints();
	raceLoop();
}

// race main loop
raceLoop()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");

	while (true)
	{
		level.raceStarted = false;
		level.raceCanJoin = true;
		cleanRaceHud();
		// wait atleast 2 players in the lobby.
		while (level.racePlayers.size < 2)
			wait 1;

		// check if race can start
		if (!check_race_condition())
		{
			wait 1;
			continue;
		}
		exec("say ^3Race start in 10sec! ^7[^2!joinrace !leaverace^7]");
		wait 10;
		level.raceCanJoin = false;

		// start race
		threadOnAllRacers(::race_place_player);
		race_countdown();
		startRace();
		exec("say ^2Race lobby is open!");
		wait 1;
	}
}

// race starting countdown
race_countdown()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");

	for (i = 10; i != 0; i--)
	{
		wait 1;
		callOnAllRacers(::setLowerMessage, i - 1);
		if (i == 7)
			callOnAllRacers(::player_freeze);
	}
	wait 1;
	threadOnAllRacers(::player_go);
}

// freeze all player before the race starts.
player_freeze()
{
	self endon("disconnect");

	self freezeControls(false);
	self setVelocity((0, 0, 0));
	self setOrigin(level.raceSpawn.origin);
	self setPlayerAngles(level.raceSpawn.angles);
	self linkTo(level.tempEntity);
}

// player code when race start
player_go()
{
	self unlink();
	self clearLowerMessage();
	self iPrintLnBold("^3GO!");
	if (isDefined(self.timerHud[4]))
		self.timerHud[4] setTenthsTimerUp( 0.0001 );
	self.raceTime = getTime();
	self thread player_die();
}

// when player die after the race start
player_die()
{
	self endon("disconnect");
	self notify("race die reset");
	wait 0.05;
	self endon("race die reset");

	self waittill("death");
	self iPrintLn("^1You died, wait till the race end.");
	self.inRaceDead = true;
	self setVelocity((0, 0, 0));
	ori = self getOrigin();
	self setOrigin((ori[0], ori[1], ori[2] + 100));
	self linkTo(level.tempEntity);
}

// when race start, switch player's team.
race_place_player()
{
	self endon("disconnect");

	self.inRace = true;
	self.inRaceDead = false;
	self.inRaceFinish = false;
	self suicide();
	self braxi\_mod::respawn();
	self freezeControls(true);
	wait 0.3;
	if (isDefined(self.timerHud[4]))
		self.timerHud[4] setText("^50:00.0");
}

// update the race scoreboard
// player = the player who won.
updateScoreHud(player)
{
	level endon("game over");
	level endon("intermission");

	// update winner score
	if (isDefined(player))
		player.raceWon++;

	// update all score
	players = getEntArray("player", "classname");
	for (p = 0; p < players.size; p++)
	{
		if (isDefined(players[p]) && players[p].inRace)
		{
			for (i = 0; i < level.raceScoreboard.size; i++)
			{
				if (level.raceScoreboard[i]["guid"] == players[p].playerID)
					level.raceScoreboard[i]["score"] = players[p].raceWon;
			}
		}
	}
	// sort scores array
	level.raceScoreboard = sortScores(level.raceScoreboard);

	// generate hud string
	hudString = "^7[Race Score]\n";
	for (i = 0; i < level.raceScoreboard.size; i++)
	{
		if (i >= 6) break;
		hudString += getPositionColorString(i + 1) + "[" + level.raceScoreboard[i]["score"] + "] "
			+ level.raceScoreboard[i]["name"] + "\n";
	}
	// display hud string
	for (i = 0; i < players.size; i++)
		if (isDefined(players[i]) && players[i].inRace)
			players[i].raceScoreHud setText(hudString);
}

// bubble sort score entry
sortScores(a)
{
	// sort
	temp = 0;
	for (i = 0; i < a.size; i++)
	{
		for (j = i + 1; j < a.size; j++)
		{
			if (a[j]["score"] < a[i]["score"])
			{
				temp = a[i];
				a[i] = a[j];
				a[j] = temp;
			}
		}
	}

	// reverse
	arr = [];
	for (i = 0; i < a.size; i++)
		arr[i] = a[a.size - 1 - i];
	return arr;
}

// reset race spawn to masterspawn
reset_spawn()
{
	level.raceSpawn = level.masterspawn;
	self iPrintLnBold("Reset race spawn point");
}

// reset race entrig to level endmap_trig
reset_endTrig()
{
	level.raceEndTrig = getEnt("endmap_trig", "targetname");
	self iPrintLnBold("Reset race end trigger");
}

// set the race endtrig to an updated race_endtrig
cmd_setTrig()
{
	level.raceEndTrig = getEnt("race_endtrig", "targetname");
	//thread sr\game\_fx_triggers::createTrigFx(level.raceEndTrig, "green"); // TODO black/white racing flag
	self iPrintLnBold("Placed race end trigger");
}

// set the race spawn from specified param
cmd_setSpawn(ent)
{
	level.raceSpawn = ent;
	self iPrintLnBold("Placed race ent at " + ent.origin);
}

// start the race
startRace()
{
	level.raceStarted = true;
	makeRaceHud();
	watchRace();
}

// add a new point to the list
cmd_spawnPoints()
{
	level.placedPoints[level.placedPoints.size] = self GetOrigin();
	self IPrintLnBold("Points placed " + level.placedPoints.size );
}

// save all point to file
cmd_savePoints()
{
	path = "./sr/data/speedrun/map_points/" + getDvar("mapname") + ".txt";
	for(i = 0; i < level.placedPoints.size; i++)
		WriteToFile(path,  level.placedPoints[i]);
	self IPrintLnBold("Points saved");
	loadAllPoints();
	self iPrintLnBold("Points loaded");
}

// get points from txt file
loadAllPoints()
{
	path = "./sr/data/speedrun/map_points/" + getDvar("mapname") + ".txt";
	if(!checkfile(path))
	{
		IPrintLn("No race points");
		return;
	}

	a = readAll(path);
	for(i = 0; i < a.size; i++)
	{
		tkn = StrTok(GetSubStr(a[i], 1, a[i].size - 1), ",");
		if (tkn.size >= 3)
			level.racePoints[i] = (int(tkn[0]), int(tkn[1]), int(tkn[2]));
	}
}

// spawn racers hud
makeRaceHud()
{
	players = getEntArray( "player", "classname" );
	for (i = 0; i < players.size; i++)
	{
		if (isDefined(players[i]) && players[i].inRace)
		{
			players[i].raceHud = addHud(players[i], 18, -15, 1, "left", "bottom", 4);
			if (!isDefined(players[i].raceScoreHud))
				players[i].raceScoreHud = addHud(players[i], -2, -20, 1, "right", "middle", 1.4);
		}
	}
}

// clean racers hud
cleanRaceHud()
{
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
		if (isDefined(players[i]) && isDefined(players[i].raceHud))
			players[i].raceHud destroy();
}

// command to join the race
cmd_joinRace()
{
	if (!level.raceCanJoin)
	{
		self iprintlnbold("^1Race already started!");
		return;
	}
	for (i = 0; i < level.racePlayers.size; i++)
		if (level.racePlayers[i] == self)
			return;
	self addToScoreboard();
	level.racePlayers[level.racePlayers.size] = self;
	self.sr_cheatmode = true;
	exec("say " + self.name + " ^7joined the race! [^2!joinrace !leaverace^7] [^1" + level.racePlayers.size + "^7]");
}

// add player in the scoreboard
addToScoreboard()
{
	for (i = 0; i < level.raceScoreboard.size; i++)
		if (level.raceScoreboard[i]["guid"] == self.playerID)
			return;

	entry = [];
	entry["name"] = self.name;
	entry["score"] = self.raceWon;
	entry["guid"] = self.playerID;
	level.raceScoreboard[level.raceScoreboard.size] = entry;
}

// command to leave the race
cmd_leaveRace()
{
	self endon("disconnect");

	self.inRace = false;
	removePlayer(self);
	if (isDefined(self.raceHud))
		self.raceHud destroy();
	if (isDefined(self.raceScoreHud))
		self.raceScoreHud destroy();
	self suicide();
	self unlink();
	self.sr_cheatmode = false;
}

// remove a player from racers
removePlayer(player)
{
	arr = [];
	for (i = 0; i < level.racePlayers.size; i++)
	{
		if (isDefined(level.racePlayers[i]) && level.racePlayers[i] == player)
			continue;
		arr[i] = level.racePlayers[i];
	}
	level.racePlayers = arr;
}

// remove a player from specified index
removePlayerIndex(index)
{
	arr = [];
	for (i = 0; i < level.racePlayers.size; i++)
	{
		if (i == index)
			continue;
		arr[i] = level.racePlayers[i];
	}
	level.racePlayers = arr;
}

// check if the race can start
check_race_condition()
{
	if (!isDefined(level.raceEndTrig))
	{
		iPrintLn("^1RACE ERROR: Race end trig not found.");
		cleanRaceHud();
		playersLeaveRace();
		return false;
	}
	if (level.racePoints.size <= 0)
	{
		iPrintLn("^1RACE ERROR: Race points not found.");
		cleanRaceHud();
		playersLeaveRace();
		return false;
	}
	return true;
}

// watch end trig
watchRaceEndTrig()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level endon("race ended");

	thread watchEnd();
	thread watchAllDied();

	while (true)
	{
		level.raceEndTrig waittill("trigger", player);
		if (!player.inRaceFinish)
			player thread player_endRace();
	}
}

// watch if everyone died
watchAllDied()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level endon("race ended");

	while (true)
	{
		anyRacing = false;
		for (i = 0; i < level.racePlayers.size; i++)
		{
			if (isDefined(level.racePlayers[i]))
			{
				if (!level.racePlayers[i].inRaceDead && !level.racePlayers[i].inRaceFinish)
				{
					anyRacing = true;
					break;
				}
			}
		}
		if (!anyRacing)
			level notify("race ended");
		wait 1;
	}
}

// watch end race
watchEnd()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level endon("race ended");

	startEndCountdown = false;
	while (true)
	{
		level.raceEndTrig waittill("trigger");
		if (!startEndCountdown)
		{
			startEndCountdown = true;
			thread endRace_countdown();
		}
		if (level.racePlayers.size == level.racePlayersFinished.size)
			level notify("race ended");
	}
}

// player on end_trig
player_endRace()
{
	self endon("disconnect");
	posIndex = level.racePlayersFinished.size;

	self.inRaceFinish = true;
	if (isDefined(self.raceHud))
		self.raceHud destroy();
	self linkTo(level.tempEntity);

	for (i = 0; i < level.racePlayersFinished.size; i++)
		if (level.racePlayersFinished[i] == self)
			return;
	level.racePlayersFinished[level.racePlayersFinished.size] = self;
	self braxi\_rank::giveRankXP(int(speedrun\game\_leaderboard::xpamount()[posIndex] / 2));

	self.time = speedrun\game\_leaderboard::realtime(getTime() - self.raceTime);
	position = getPositionString(posIndex + 1);
	self thread speedrun\player\_hud_speedrun::updateHud();

	sayToAllRacers(self.name + " ^7finished " + position + " ^7in ^2"
		+ self.time.min + ":" + self.time.sec + "." + self.time.milsec);
	if (posIndex + 1 == 1)
		updateScoreHud(self);
}

// call a function on all racers
callOnAllRacers(func, arg)
{
	for (i = 0; i < level.racePlayers.size; i++)
	{
		if (isDefined(level.racePlayers[i]))
		{
			if (isDefined(arg))
				level.racePlayers[i] [[func]](arg);
			else
				level.racePlayers[i] [[func]]();
		}
	}
}

// thread a function on all racers
threadOnAllRacers(func, arg)
{
	for (i = 0; i < level.racePlayers.size; i++)
	{
		if (isDefined(level.racePlayers[i]))
		{
			if (isDefined(arg))
				level.racePlayers[i] thread [[func]](arg);
			else
				level.racePlayers[i] thread [[func]]();
		}
	}
}

// send a message on all racers
sayToAllRacers(msg)
{
	for (i = 0; i < level.racePlayers.size; i++)
		if (isDefined(level.racePlayers[i]))
			level.racePlayers[i] iPrintLnBold(msg);
}

// race end countdown if people dont finish in time
endRace_countdown()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level endon("race ended");

	wait 5;
	exec("say ^3Race end in 30secs!");

	wait 30;
	level notify("race ended");
}

// check if there is still enough players for a race
checkRequiredPlayers()
{
	players = getEntArray("player", "classname");
	count = 0;
	for (i = 0; i < players.size; i++)
		if (isDefined(players[i]) && players[i].inRace)
			count++;

	if (count < 2)
	{
		cleanRaceHud();
		playersLeaveRace();
		level.raceScoreboard = [];
		resetPlayersScore();
		level notify("race ended");
	}
}

// reset players score to 0
resetPlayersScore()
{
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
		if (isDefined(players[i]))
			players[i].raceWon = 0;
}

// abort run 3mins after it start
watchTimer()
{
	level endon("race ended");
	wait 180;
	level notify("race ended");
}

// main race code
watchRace()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level notify("race ended");
	wait 0.05;
	level endon("race ended");

	for(i = 0; i < level.racePlayers.size; i++)
		level.racePlayers[i].closestPoint = 0;

	// reset placements
	level.racePlayersFinished = [];
	thread watchRaceEndTrig();
	thread watchTimer();

	while(1)
	{
		checkRequiredPlayers();

		//get players closest point
		for(i=0; i<level.racePlayers.size; i++)
		{
			for(z=0; z<level.racePoints.size; z++)
			{
				if (!isDefined(level.racePlayers[i]))
				{
					removePlayerIndex(i);
					continue;
				}
				newDist = Distance2D(level.racePlayers[i] GetOrigin(), level.racePoints[z]);
				oldDist = Distance2D(level.racePlayers[i] GetOrigin(), level.racePoints[level.racePlayers[i].closestPoint]);
				if(newDist < oldDist)
					level.racePlayers[i].closestPoint = z;
			}
		}

		//see who is closest to the highest point
		level.racePlayersOrder = [];
		idx = 0;
		for(z=level.racePoints.size; z>=0; z--)
		{
			for(i=0; i<level.racePlayers.size; i++)
			{
				if (!isDefined(level.racePlayers[i]))
				{
					removePlayerIndex(i);
					continue;
				}
				if(level.racePlayers[i].closestPoint == z)
				{
					level.racePlayersOrder[idx] = level.racePlayers[i];
					idx++;
				}
			}
		}

		//check if multiple players have the same highest point
		temp = 0;
		for(t=0; t<level.racePlayersOrder.size; t++)
		{
			for(i=0; i<level.racePlayersOrder.size-1; i++)
			{
				if (!isDefined(level.racePlayers[i]))
				{
					removePlayerIndex(i);
					continue;
				}
				if(level.racePlayersOrder[i].closestPoint == level.racePlayersOrder[i+1].closestPoint)
				{
					dist1 = undefined;
					dist2 = undefined;
					if (isDefined(level.racePoints[level.racePlayersOrder[i].closestPoint+1]))
						dist1 = Distance2D(level.racePlayersOrder[i] GetOrigin(), level.racePoints[level.racePlayersOrder[i].closestPoint+1]);
					if (isDefined(level.racePoints[level.racePlayersOrder[i+1].closestPoint+1]))
						dist2 = Distance2D(level.racePlayersOrder[i+1] GetOrigin(), level.racePoints[level.racePlayersOrder[i+1].closestPoint+1]);

					if(isDefined(dist1) && isDefined(dist2) && dist1 > dist2)
					{
						temp = level.racePlayersOrder[i+1];
						level.racePlayersOrder[i+1] = level.racePlayersOrder[i];
						level.racePlayersOrder[i] = temp;
					}
				}
			}
		}
		updateRaceHud(level.racePlayersOrder);
		wait 0.1;
	}
}

// make all player leave the race
playersLeaveRace()
{
	level.racePlayers = [];
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
		if (isDefined(players[i]) && players[i].inRace)
			players[i] cmd_leaveRace();
}

// update racers placement hud
updateRaceHud(players)
{
	for(i = 0; i < players.size; i++)
	{
		position = getPositionString(i + 1);
		if (isDefined(players[i]) && isDefined(players[i].raceHud))
			players[i].raceHud setText(position);
	}
}

// get a position string from index
getPositionString(index)
{
	switch (index)
	{
		case 1: 	return "^31st";
		case 2: 	return "^82nd";
		case 3: 	return "^93rd";
		default: 	return "^7" + index + "th";
	}
}

// get a string color from index
getPositionColorString(index)
{
	switch (index)
	{
		case 1:		return "^3";
		case 2:		return "^8";
		case 3:		return "^9";
		default:	return "^7";
	}
}

// create specific hud elem
addHud(who, x, y, alpha, alignX, alignY, fontScale)
{
	if(isPlayer(who))
		hud = newClientHudElem(who);
	else
		hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.alignX = alignX;
	hud.alignY = alignY;
	hud.horzAlign = alignX;
    hud.vertAlign = alignY;
	hud.font = "objective";
 	hud.hidewheninmenu = true;
	hud.fontScale = fontScale;
	return hud;
}

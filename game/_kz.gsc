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
#include sr\sys\_common;
#include braxi\_common;

init()
{
	level.kzPoints = [];
	level.kzPlayers = [];
	level.kzPlayersInRoom = [];
	level.kzRandomPoints = [];
	level.kzWeapon = "knife_mp";
	level.kzWeaponMode = "rng";
	level.kzWeaponList = strTok("m40a3_mp,g3_reflex_mp,m1014_mp,m14_mp,ak47_mp,mp5_acog_mp,ak47_gl_mp,g36c_silencer_mp,m1014_grip_mp,mp5_mp,gl_m14_mp,m60e4_mp,dragunov_mp,p90_acog_mp,rpg_mp,knife_mp", ",");
	level.kzStarted = false;

	level waittill("game started");
	loadAllPoints();
	kzLoop();
}

// kz main loop
kzLoop()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");

	while (true)
	{
		// wait atleast 2 players in the lobby.
		level.kzStarted = false;
		while (level.kzPlayers.size < 2)
			wait 1;
		level.kzPlayersInRoom = [];
		level.kzRandomPoints = [];

		// check if kz can start
		if (!check_kz_condition())
		{
			wait 1;
			continue;
		}

		// start kz
		randomize_game();
		draw_player_cards();
		send_players();
		watchKzGame();
		wait 1;
	}
}

// draw a player card
showPlayerCard( attacker, victim, text )
{
	self endon("disconnect");

	if( attacker == victim || !isPlayer( attacker ) )
		return;

	self notify( "new emblem" );	// one instance at a time
	self endon( "new emblem" );

	self destroyPlayerCard();

	logo1 = level.rankIconInfo[attacker.pers["rank"] - 1]["icon"];
	logo2 = level.rankIconInfo[victim.pers["rank"] - 1]["icon"];

	if (attacker.pers["prestige"] > 0)
		logo1 = "rank_prestige" + attacker.pers["prestige"];
	if (victim.pers["prestige"] > 0)
		logo2 = "rank_prestige" + victim.pers["prestige"];

	self.playerCard[0] = newClientHudElem( self );
	self.playerCard[0].x = 170;
	self.playerCard[0].y = 390;
	self.playerCard[0].alpha = 0;
	self.playerCard[0] setShader( "black", 300, 64 );
	self.playerCard[0].sort = 990;

	//logos
	self.playerCard[1] = braxi\_mod::addTextHud( self, 0, 390, 0, "left", "top", 1.8 );
	self.playerCard[1] setShader( logo1, 64, 64 );
	self.playerCard[1].sort = 998;

	self.playerCard[2] = braxi\_mod::addTextHud( self, 640, 390, 0, "left", "top", 1.8 );
	self.playerCard[2] setShader( logo2, 64, 64 );
	self.playerCard[2].sort = 998;

	self.playerCard[3] = braxi\_mod::addTextHud( self, 320, 390, 0, "center", "top", 1.6 );
	self.playerCard[3] setText( text );
	self.playerCard[3].sort = 999;

	self.playerCard[4] = braxi\_mod::addTextHud( self, 320, 420, 0, "center", "top", 1.5 );
	self.playerCard[4] setText( attacker.name + " ^7 VS ^7 " + victim.name );
	self.playerCard[4].sort = 999;

	for( i = 3; i < 5; i++ )
	{
		self.playerCard[i].color = (0.8,0.8,0.8);
		self.playerCard[i].glowColor = (0.6,0.6,0.6);
		self.playerCard[i] SetPulseFX( 30, 100000, 700 );
		self.playerCard[i].glowAlpha = 0.8;
	}

	// === animation === //
	self.playerCard[1] moveOverTime( 0.44 );
	self.playerCard[1].x = 170;
	self.playerCard[2] moveOverTime( 0.44 );
	self.playerCard[2].x = 170+300-64;
	for( i = 0; i < self.playerCard.size; i++ )
	{
		self.playerCard[i] fadeOverTime( 0.3 );

		if( i == 0 ) // hack
			self.playerCard[i].alpha = 0.5;
		else
			self.playerCard[i].alpha = 1.0;
	}
	wait 3;

	for( i = 0; i < self.playerCard.size; i++ )
	{
		self.playerCard[i] fadeOverTime( 0.8 );
		self.playerCard[i].alpha = 0;
	}
	wait 0.8;

	self destroyPlayerCard();
}

// show a player card to all kz players
draw_player_cards()
{
	for (i = 0; i < level.kzPlayers.size; i++)
		if (isDefined(level.kzPlayers[i]))
			level.kzPlayers[i] thread showPlayerCard(level.kzPlayersInRoom[0], level.kzPlayersInRoom[1], "");
}

// destroy the player card hud
destroyPlayerCard()
{
	if( !isDefined( self.playerCard ) || !self.playerCard.size )
		return;

	for( i = 0; i < self.playerCard.size; i++ )
		self.playerCard[i] destroy();
	self.playerCard = [];
}

// set kz weapon
setWeapon(weap)
{
	if (weap == "rng")
	{
		level.kzWeaponMode = "rng";
		level.kzWeapon = level.kzWeaponList[randomIntRange(0, level.kzWeaponList.size)];
	}
	else
	{
		level.kzWeaponMode = "manual";
		level.kzWeapon = weap;
	}
}

// send picked players to the map, other in spec
send_players()
{
	for (i = 0; i < level.kzPlayers.size; i++)
		if (isDefined(level.kzPlayers[i]))
			level.kzPlayers[i] spawnPlayerToSpec();

	for (i = 0; i < level.kzPlayersInRoom.size; i++)
		if (isDefined(level.kzPlayersInRoom[i]))
			level.kzPlayersInRoom[i] spawnPlayersInRoom();
}

// spawn selected player to kz room
spawnPlayersInRoom()
{
	// regen rng weapons
	if (level.kzWeaponMode == "rng")
		setWeapon("rng");

	for (i = 0; i < level.kzPlayersInRoom.size; i++)
		if (isDefined(level.kzPlayersInRoom[i]))
			level.kzPlayersInRoom[i] thread spawnPlayersInRoom_thread(i);
}

// spawn and give stuff to selected player, i = index of the player in level.kzPlayersInRoom
spawnPlayersInRoom_thread(i)
{
	self endon("disconnect");

	self.wonKz = false;
	self braxi\_teams::setTeam("axis");
	self suicide();

	self endon("death");
	self braxi\_mod::spawnPlayer(level.kzRandomPoints[i].origin, level.kzRandomPoints[i].angles);
	self takeAllWeapons();
	self giveWeapon(level.kzWeapon);
	self giveMaxAmmo(level.kzWeapon);
	wait 0.05;
	self switchToWeapon(level.kzWeapon);
	self setClientDvar("cg_drawFriendlyNames", 0);
}

// watch game 2min max
watchGameTimer()
{
	level endon("kz ended");
	wait 120;
	level notify("kz ended");
}

// watch the kz game
watchKzGame()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level notify("kz ended");
	wait 0.05;
	level endon("kz ended");

	level.kzStarted = true;
	thread watchGameTimer();

	while (true)
	{
		// check if room players are alive
		allDied = true;
		for (i = 0; i < level.kzPlayersInRoom.size; i++)
		{
			if (isDefined(level.kzPlayersInRoom[i]) && level.kzPlayersInRoom[i] isReallyAlive()
				&& level.kzPlayersInRoom[i].sessionstate == "playing")
				allDied = false;
			else
			{
				allDied = true;
				break;
			}
		}
		if (level.kzPlayersInRoom.size < 2)
			allDied = true;

		// remove undefined player
		for (i = 0; i < level.kzPlayers.size; i++)
			if (!isDefined(level.kzPlayers[i]))
				removePlayerIndex(i);

		// remove undefined room player
		for (i = 0; i < level.kzPlayersInRoom.size; i++)
			if (!isDefined(level.kzPlayersInRoom[i]))
				removeRoomPlayerIndex(i);

		// end match
		if (allDied)
		{
			winner = undefined;
			for (i = 0; i < level.kzPlayersInRoom.size; i++)
				if (isDefined(level.kzPlayersInRoom[i]) && level.kzPlayersInRoom[i].wonKz)
					winner = level.kzPlayersInRoom[i];

			if (isDefined(winner))
			{
				level.kzStarted = false;
				winner.kzWon++;
				winner.time = speedrun\game\_leaderboard::realtime(getTime() - winner.timerStartTime);
				winner thread speedrun\player\_hud_speedrun::updateHud();
				wait 3;
				winner spawnPlayerToSpec();
			}
			level notify("kz ended");
		}
		wait 0.4;
	}
}

// pick 2 random players and random room points
randomize_game()
{
	level endon("kz ended");

	// get random players
	r1 = undefined;
	r2 = undefined;
	while (!isDefined(r1) || !isDefined(r2) || isDefined(r1) && isDefined(r2) && r1 == r2)
	{
		r1 = level.kzPlayers[randomIntRange(0, level.kzPlayers.size)];
		r2 = level.kzPlayers[randomIntRange(0, level.kzPlayers.size)];
		wait 0.1;
	}
	level.kzPlayersInRoom[0] = r1;
	level.kzPlayersInRoom[1] = r2;

	// get random room points
	r = 1;
	while (r % 2 == 1)
		r = randomIntRange(0, level.kzPoints.size);
	level.kzRandomPoints[0] = level.kzPoints[r];
	level.kzRandomPoints[1] = level.kzPoints[r + 1];
}

// check if the kz can start
check_kz_condition()
{
	if (level.kzPoints.size <= 0)
	{
		iPrintLn("^1KZ ERROR: Kz points not found.");
		playersLeaveKz();
		return false;
	}
	return true;
}

// make all player leave the kz
playersLeaveKz()
{
	level.kzPlayers = [];
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
		if (isDefined(players[i]) && players[i].inKz)
			players[i] leaveKz();
}

// add a new point to the list
spawnPoints()
{
	ent = spawnStruct();
	ent.origin = self GetOrigin();
	ent.angles = self getPlayerAngles();
	level.placedPoints[level.placedPoints.size] = ent;
	self IPrintLnBold("Points placed " + level.placedPoints.size );
}

// save all point to file
savePoints()
{
	path = "./sr/data/speedrun/kz_points/" + getDvar("mapname") + ".txt";
	if (level.placedPoints.size % 2 == 1)
	{
		self iPrintLnBold("^1Points failed to save.");
		return;
	}

	for(i = 0; i < level.placedPoints.size; i++)
	{
		vec = level.placedPoints[i].origin;
		angle = level.placedPoints[i].angles[1];
		WriteToFile(path, "" + vec[0] + "," + vec[1] + "," + vec[2] + "," + angle);
	}
	self IPrintLnBold("Points saved");
	loadAllPoints();
	self iPrintLnBold("Points loaded");
}

// command to join the kz
joinKz()
{
	self endon("disconnect");
	for (i = 0; i < level.kzPlayers.size; i++)
		if (isDefined(level.kzPlayers[i]) && level.kzPlayers[i] == self)
			return;

	level.kzPlayers[level.kzPlayers.size] = self;
	self.sr_cheatmode = true;
	self.inKz = true;
	self.canDamage = true;
	self spawnPlayerToSpec();
	exec("say " + self.name + " ^7joined the killzone! [^6!joinkz !leavekz^7] [^1" + level.kzPlayers.size + "^7]");
}

// send player to spec
spawnPlayerToSpec()
{
	self endon("disconnect");
	self braxi\_teams::setTeam( "spectator" );
	self braxi\_mod::spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
	// if(self.pers["spec_hud"] == 1 )
	// 	self thread speedrun\player\_hud_spectator::init();
	// self thread sr\commands\_hud_cheat::spec();
}

// command to leave the kz
leaveKz()
{
	self endon("disconnect");

	self.inKz = false;
	self.kzWon = 0;
	self.wonKz = false;
	self braxi\_teams::setTeam("allies");
	self suicide();

	removePlayer(self);
	removeRoomPlayer(self);

	self unlink();
	self.sr_cheatmode = false;
	self.canDamage = undefined;
	self setClientDvar("cg_drawFriendlyNames", 1);
	self braxi\_mod::respawn();
	self suicide();
}

// remove a plyer from kz room players
removeRoomPlayer(player)
{
	for (i = 0; i < level.kzPlayersInRoom.size; i++)
	{
		if (isDefined(level.kzPlayersInRoom[i]) && level.kzPlayersInRoom[i] == player)
		{
			level.kzPlayersInRoom = [];
			break;
		}
	}
}

// remove a plyer from kz room players from index
removeRoomPlayerIndex(index)
{
	arr = [];
	for (i = 0; i < level.kzPlayersInRoom.size; i++)
	{
		if (i == index)
			continue;
		arr[i] = level.kzPlayersInRoom[i];
	}
	level.kzPlayersInRoom = arr;
}

// remove a player from kz players
removePlayer(player)
{
	arr = [];
	for (i = 0; i < level.kzPlayers.size; i++)
	{
		if (isDefined(level.kzPlayers[i]) && level.kzPlayers[i] == player)
			continue;
		arr[i] = level.kzPlayers[i];
	}
	level.kzPlayers = arr;
}

// remove a player from specified index
removePlayerIndex(index)
{
	arr = [];
	for (i = 0; i < level.kzPlayers.size; i++)
	{
		if (i == index)
			continue;
		arr[i] = level.kzPlayers[i];
	}
	level.kzPlayers = arr;
}

// get points from txt file
loadAllPoints()
{
	path = "./sr/data/speedrun/kz_points/" + getDvar("mapname") + ".txt";
	if(!checkfile(path))
	{
		IPrintLn("No kz points");
		return;
	}

	a = readAll(path);
	for(i = 0; i < a.size; i++)
	{
		tkn = StrTok(a[i], ",");
		if (tkn.size >= 4)
		{
			ent = spawnStruct();
			ent.origin = (int(tkn[0]), int(tkn[1]), int(tkn[2]));
			ent.angles = (0, int(tkn[3]), 0);
			level.kzPoints[i] = ent;
		}
	}
}

// call a function on all kz players
callOnAllKz(func, arg)
{
	for (i = 0; i < level.kzPlayers.size; i++)
	{
		if (isDefined(level.kzPlayers[i]))
		{
			if (isDefined(arg))
				level.kzPlayers[i] [[func]](arg);
			else
				level.kzPlayers[i] [[func]]();
		}
	}
}

// thread a function on all kz players
threadOnAllKz(func, arg)
{
	for (i = 0; i < level.kzPlayers.size; i++)
	{
		if (isDefined(level.kzPlayers[i]))
		{
			if (isDefined(arg))
				level.kzPlayers[i] thread [[func]](arg);
			else
				level.kzPlayers[i] thread [[func]]();
		}
	}
}

// send a message on all kz players
sayToAllKz(msg)
{
	for (i = 0; i < level.kzPlayers.size; i++)
		if (isDefined(level.kzPlayers[i]))
			level.kzPlayers[i] iPrintLnBold(msg);
}

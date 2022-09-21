#include sr\sys\_events;
#include sr\game\minigames\_main;
#include sr\utils\_common;

initBomberman()
{
	createMinigame("bomberman");

	level.bombermanGrid = [];
	level.bombermanOrigin = (6647, -9666, 65);
	level.bombermanSpawns = [];
	level.bombermanStarted = false;
	level.bombermanMaxX = 12;
	level.bombermanMaxY = 12;
	level.bombermanAllowed = false;

	event("spawn", ::onSpawn);

	thread bomberman();
}

bomberman()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");

	while (true)
	{
		level.bombermanStarted = false;

		wait 1;
		if (!canStart())
			continue;

		level.bombermanPlayersInRoom = [];

		createGrid(12, 12);
		sendPlayers();
		watchGame();

		wait 6;
	}
}

onSpawn()
{
	if (!isInQueue("bomberman"))
		return;

	self waittill("speedrun_hud");
	self.run = "Bomberman";
	self.huds["speedrun"]["name"] setText("^3Bomberman");
	// self.huds["speedrun"]["row2"] setText(fmt("Bombs             ^2%d", self.health));
	// self.huds["speedrun"]["row3"] setText(fmt("Bonus                    ^3%d/%d", self.kills, self.deaths));
}

join()
{
	self addToQueue("bomberman");

	self sr\sys\_admins::message(fmt("%s ^7joined bomberman! [^3!bomberman^7] [^1%d^7]",
		self.name, level.minigames["bomberman"].queue.size));
}

leave()
{
	level.bombermanPlayersInRoom = Remove(level.bombermanPlayersInRoom, self);
	self removeFromQueue("bomberman");
	self setClientDvar("cg_drawFriendlyNames", 1);
	self setClientDvar("cg_thirdPerson", 0);
	self setClientDvar("cg_thirdPersonRange", 120);
	self unlink();
	self sr\game\_teams::setTeam("allies");
	self.bombermanWon = false;
	self.teamKill = undefined;

	self sr\sys\_admins::pm("You left bomberman!");
	self suicide();
}

sendPlayers()
{
	level.bombermanSpawns = pickRandom(getSpawns(), 4);
	level.bombermanPlayersInRoom = pickRandomPlayers("bomberman", 1);

	for (i = 0; i < level.minigames["bomberman"].queue.size; i++)
		level.minigames["bomberman"].queue[i] spawnPlayerInSpec();
	for (i = 0; i < level.bombermanPlayersInRoom.size; i++)
		level.bombermanPlayersInRoom[i] thread spawnPlayerInRoom(i);
}

spawnPlayerInRoom(spawnIndex)
{
	self endon("disconnect");

	self.bombs = 1;
	self.bombRadius = 64;

	self.teamKill = true;
	self.bombermanWon = false;
	self sr\game\_teams::setTeam("axis");
	self setClientDvar("cg_thirdPerson", 1);
	self setClientDvar("cg_thirdPersonRange", 500);

	spawn = spawnStruct();
	spawn.origin = level.bombermanSpawns[spawnIndex].origin;
	spawn.angles = (0, 0, 0);

	self eventSpawn(true, spawn);
	self takeAllWeapons();
	self thread watchPlayer();

	self allowJump(false);
	self allowSprint(false);
}

spawnPlayerInSpec()
{
	self endon("disconnect");
	self.teamKill = undefined;
	self sr\game\_teams::setTeam("spectator");
	self eventSpectator(true);
}

watchGameTimer()
{
	level endon("bomberman ended");
	wait 60 * 4;
	level notify("bomberman ended");
}

watchGame()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level notify("bomberman ended");
	level endon("bomberman ended");

	level.bombermanStarted = true;
	thread watchGameTimer();

	while (true)
	{
		wait 0.5;

		if (!Any(level.bombermanPlayersInRoom, ::isRoomEmpty))
			continue;

		level.bombermanStarted = false;
		level notify("bomberman ended");
	}
}

watchPlayer()
{
	level endon("bomberman ended");
	self endon("death");
	self endon("disconnect");

	while (true)
	{
		while (!self.bombs || !self useButtonPressed())
			wait 0.05;

		self thread spawnBomb();

		while (self useButtonPressed())
			wait 0.05;
		wait 0.1;
	}
}

spawnBomb()
{
	self.bombs--;

	bomb = spawnStruct();
	bomb.owner = self;
	bomb.origin = self.origin;
	bomb.radius = self.bombRadius;

	bomb.model = spawn("script_model", bomb.origin);
	bomb.model setModel("chicken");

	wait 3;

	bomb bombRadius();
	playFX(level.fx["explosion"], bomb.origin);
	bomb.model delete();

	self.bombs++;
}

bombRadius()
{
	for (x = 0; x < level.bombermanMaxX; x++)
	{
		for (y = 0; y < level.bombermanMaxY; y++)
		{
			wall = level.bombermanGrid[x][y];
			if (!wall isDestructible())
				continue;

			intersected = wall collisionIntersectRadius(self.origin, self.radius);
			if (intersected.size > 0)
				wall removeWall();

			self bombDamage();
		}
	}
}

bombDamage()
{
	players = level.bombermanPlayersInRoom;
	for (i = 0; i < players.size; i++)
	{
		if (players[i] == self.owner)
			continue;

		if (distance2D(players[i].origin, self.origin) <= self.radius)
			players[i] suicide();
	}
}

collisionIntersectRadius(pointA, radius)
{
	intersected = [];

	for (i = 0; i < self.collision.points.size; i++)
	{
		pointB = self.collision.points[i];
		if (distance2D(pointA, pointB) <= radius)
			intersected[intersected.size] = pointB;
	}
	return intersected;
}

createGrid(maxX, maxY)
{
	level.bombermanMaxX = maxX;
	level.bombermanMaxY = maxY;

	// Remove
	for (x = 0; x < level.bombermanGrid.size; x++)
	{
		for (y = 0; y < maxY; y++)
			level.bombermanGrid[x][y] removeWall();
	}
	level.bombermanGrid = [];

	// Create
	for (x = 0; x < maxX; x++)
	{
		level.bombermanGrid[x] = [];

		for (y = 0; y < maxY; y++)
		{
			origin = level.bombermanOrigin + (64 * x, 64 * y, 0);

			level.bombermanGrid[x][y] = spawnStruct();
			level.bombermanGrid[x][y] createWall(x, y);
		}
	}
}

createWall(x, y)
{
	self.active = true;
	self.origin = level.bombermanOrigin + (64 * x, 64 * y, 0);

	self.x = x;
	self.y = y;

	self.wh = spawnStruct();
	self.wh.x = 64;
	self.wh.y = 64;

	self.grid = spawnStruct();
	self.grid.x = x + 1;
	self.grid.y = y + 1;

	self.isSpawn = self isSpawn();
	self.isBorder = self isBorder();

	self.model = spawn("script_model", self.origin);
	self.model setModel("ch_crate64x64");
	if (self.isSpawn)
		self.model delete();

	self.collision = self createCollision();
}

createCollision()
{
	collision = spawnStruct();

	if (!self.isSpawn)
	{
		collision.entity = spawn("trigger_radius", self.origin, 0, self.wh.x, self.wh.y);
		collision.entity setContents(true);
		collision.entity.radius = self.wh.x;
	}

	points = [];
	points[0] = self.origin + (0, 0, 0);
	points[1] = self.origin + (self.wh.x, 0, 0);
	points[2] = self.origin + (0, self.wh.x, 0);
	points[3] = self.origin + (self.wh.x, self.wh.x, 0);

	collision.points = points;
	return collision;
}

removeCollision()
{
	if (isDefined(self.collision.entity))
		self.collision.entity delete();
}

removeWall()
{
	self.active = false;
	self removeCollision();

	if (isDefined(self.model))
		self.model delete();
}

getSpawns()
{
	spawns = [];
	for (x = 0; x < level.bombermanMaxX; x++)
	{
		for (y = 0; y < level.bombermanMaxY; y++)
		{
			if (level.bombermanGrid[x][y].isSpawn)
				spawns[spawns.size] = level.bombermanGrid[x][y];
		}
	}
	return spawns;
}

isRoomEmpty(player, index)
{
	return level.bombermanPlayersInRoom.size < 2 || !player isReallyAlive();
}

isBorder()
{
	if (self.grid.x == 1 || self.grid.y == 1)
		return true;
	if (self.grid.x == level.bombermanMaxX || self.grid.y == level.bombermanMaxY)
		return true;
	return false;
}

isSpawn()
{
	if (self.grid.x == 2 && self.grid.y == level.bombermanMaxY - 1)
		return true;
	if (self.grid.x == level.bombermanMaxX - 1 && self.grid.y == level.bombermanMaxY - 1)
		return true;
	if (self.grid.x == 2 && self.grid.y == 2)
		return true;
	if (self.grid.x == level.bombermanMaxX - 1 && self.grid.y == 2)
		return true;
	return false;
}

isDestructible()
{
	return self.active && !self.isSpawn && !self.isBorder;
}

canStart()
{
	return level.minigames["bomberman"].queue.size >= 2;
}

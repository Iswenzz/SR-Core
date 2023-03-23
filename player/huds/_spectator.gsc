#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

main()
{
	event("connect", ::hud);
	event("spawn", ::clear);
	event("spectate", ::clear);
}

hud()
{
	self endon("disconnect");
	self endon("killcam");

	self vars();

	while (true)
	{
		self.player = IfUndef(self getSpectatorClient(), self);
		self renderSpectateList();

		wait 0.4;

		self.prevSpectatorList = self.spectatorList;
	}
}

vars()
{
	if (self.settings["hud_spectating"])
	{
		self.huds["spectator"] = addHud(self, 4, 85, 0, "left", "top", 1.4, 1000);
		self.huds["spectator"].spectator = false;
	}
	self.spectatorList = "";
	self.spectatorWatching = 0;
	self.prevSpectatorList = "";
}

renderSpectateList()
{
	self buildSpectateList();

	spectator = self isSpectator();
	spectatingStart = spectator && self.player != self && self.player.spectatorList != "";
	spectatingEnd = spectator && self.player == self;
	playStart = self.spectatorList != "" && self.prevSpectatorList == "";
	playEnd = self.spectatorList == "" && self.prevSpectatorList != "";

	if (isDefined(self.huds["spectator"]))
	{
		moveIn = !self.huds["spectator"].alpha && (playStart || spectatingStart);
		moveOut = self.huds["spectator"].alpha && (playEnd || spectatingEnd);

		if (moveIn)
		{
			self.huds["spectator"].x = 4;
			self.huds["spectator"].alpha = 1;
			self.huds["spectator"] setText(self.player.spectatorList);
			self.huds["spectator"] moveIn(0, 1, "right", 1);
			self.huds["spectator"].spectator = spectator;
			wait 0.05;
		}
		else if (moveOut)
		{
			self.huds["spectator"].x = 4;
			self.huds["spectator"] moveOut(0, 1, "left", 1, false);
			self.huds["spectator"].alpha = 0;
			self.huds["spectator"].spectator = spectator;
			wait 0.05;
		}
		else if (self.player.spectatorList != self.player.prevSpectatorList)
			self.huds["spectator"] setText(self.player.spectatorList);
	}
}

buildSpectateList()
{
	players = getAllPlayers();

	self.spectatorWatching = 0;
	self.spectatorList = "";

	for (i = 0; i < players.size; i++)
	{
		if (players[i] == self)
			continue;
		if (players[i].player == self)
		{
			self.spectatorWatching++;
			if (self.spectatorWatching <= 5)
				self.spectatorList += " " + players[i].name + "^7\n";
		}
	}
	if (self.spectatorWatching)
		self.spectatorList = fmt("Spectating (%d)\n%s", self.spectatorWatching, self.spectatorList);
}

clear()
{
	if (isDefined(self.huds["spectator"]) && self.huds["spectator"].spectator)
		self.huds["spectator"].alpha = 0;
}

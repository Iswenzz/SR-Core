#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

main()
{
	event("connect", ::onConnect);
	event("spawn", ::hud);
	event("spectator", ::hud);
	event("death", ::clear);
}

onConnect()
{
	self.spectatorList = "";
	self.prevSpectatorList = "";
	self.spectatorWatching = 0;
}

hud()
{
	self endon("spawned");
	self endon("spectator");
	self endon("death");
	self endon("disconnect");

	self clear();
	self vars();

	while (true)
	{
		client = self getSpectatorClient();
		self.player = IfUndef(client, self);

		self.spectatorPlayer = -1;
		if (isDefined(client))
			self.spectatorPlayer = client.number;

		self renderSpectateList();

		wait 0.4;

		self.prevSpectatorPlayer = self.spectatorPlayer;
		self.prevSpectatorList = self.spectatorList;
	}
}

vars()
{
	self.huds["spectator"] = addHud(self, 4, 85, 1, "left", "top", 1.4, 1000);
	if (self.spectatorList != "" && self.settings["hud_spectating"])
		self.huds["spectator"] setText(self.spectatorList);

	self.spectatorPlayer = -1;
	self.prevSpectatorPlayer = -1;
}

renderSpectateList()
{
	self buildSpectateList();

	startSpectate = self isSpectator() && self.spectatorPlayer != -1 && self.prevSpectatorPlayer == -1;
	endSpectate = self isSpectator() && self.spectatorPlayer == -1 && self.prevSpectatorPlayer != -1;

	if (self.spectatorList == "" && self.prevSpectatorList != "" || endSpectate)
	{
		self.huds["spectator"].x = 4;
		self.huds["spectator"] moveOut(0, 1, "left", 1, false);
		self updateSpectatorList();
		wait 0.05;
	}
	if (self.prevSpectatorList == "" && self.spectatorList != "" || startSpectate)
	{
		self updateSpectatorList();
		self.huds["spectator"].x = 4;
		self.huds["spectator"] moveIn(0, 1, "right", 1);
		wait 0.05;
	}
	self updateSpectatorList();
}

updateSpectatorList()
{
	self.player buildSpectateList();
	if (self.player.spectatorList != self.player.prevSpectatorList && self.settings["hud_spectating"])
	{
		self.huds["spectator"] setText(self.player.spectatorList);
		wait 0.05;
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
	if (isDefined(self.huds["spectator"]))
		self.huds["spectator"] destroy();
}

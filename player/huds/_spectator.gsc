#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

main()
{
	event("spawn", ::hud);
	event("spectator", ::hud);
	event("death", ::clear);
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
		players = getAllPlayers();

		self.player = IfUndef(self getSpectatorClient(), self);
		self.spectatorList = "";
		self.spectatorWatching = 0;

		for (i = 0; i < players.size; i++)
		{
			if (players[i].spectatorclient == self.number)
			{
				self.spectatorWatching++;
				if (self.spectatorWatching <= 5)
					self.spectatorList += " " + players[i].name + "^7\n";
			}
		}
		if (self.spectatorWatching)
			self.spectatorList = fmt("Spectating (%d)\n%s", self.spectatorWatching, self.spectatorList);
		if (self.player.spectatorList != self.player.prevSpectatorList && self.settings["hud_spectating"])
			self.huds["spectator"] setText(self.player.spectatorList);

		wait 0.2;
		self.prevSpectatorList = self.spectatorList;
	}
}

vars()
{
	self.huds["spectator"] = addHud(self, 4, 80, 1, "left", "top", 1.4, 1000);

	self.spectatorList = "";
	self.spectatorWatching = 0;
	self.prevSpectatorList = "";
}

clear()
{
	if (isDefined(self.huds["spectator"]))
		self.huds["spectator"] destroy();
}

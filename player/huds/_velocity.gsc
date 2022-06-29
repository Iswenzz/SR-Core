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
	self endon("death");
	self endon("disconnect");
	self endon("joined_spectators");

    if (!self.settings["hud_spectator"] || !self.settings["hud_velocity"])
        return;

	wait 0.05;

	self clear();
	self hudVelocity();

	self.vels = [];
	self.groundTime = 0;
	self.groundTimes = [];
    self.prevVelocityDist = 0;
    self.prevOnGround = true;

	while (true)
	{
		player = IfUndef(self getSpectatorClient(), self);

        self.velocityDist = self getPlayerVelocity();
        self.onGround = self isOnGround();

        if (self.onGround && !self.prevOnGround)
        {
			self.vels[self.vels.size] = self.prevVelocityDist;
			self.groundTimes[self.groundTimes.size] = self.groundTime;
			self.groundTime = 0;
		}
		if (self.onGround)
			self.groundTime += 50;

		self updateVelocity(player);

		wait 0.05;

        self.prevVelocityDist = self.velocityDist;
        self.prevOnGround = self.onGround;
	}
}

hudVelocity()
{
	alignX = getHorizontal(self.settings["hud_velocity"]);
	alignY = getVertical(self.settings["hud_velocity"]);
	
	self.huds["velocity"] = [];
	self.huds["velocity"]["value"] = addHud(self, 0, 0, 1, alignX, alignY, 1.6);
	self.huds["velocity"]["value"].hidewheninmenu = true;
	self.huds["velocity"]["value"].archived = false;
	self.huds["velocity"]["value"].label = &"^5V ^7&&1";

	if (self.settings["hud_velocity_ground"])
	{
		self.huds["velocity"]["ground"] = addHud(self, -50, 0, 1, alignX, alignY, 1.6);
		self.huds["velocity"]["ground"].hidewheninmenu = true;
		self.huds["velocity"]["ground"].archived = false;
		self.huds["velocity"]["ground"].label = &"^2G ^7&&1";
		self.huds["velocity"]["ground"] setValue(0);
	}
	if (self.settings["hud_velocity_info"] >= 1)
	{
		self.huds["velocity"]["average"] = addHud(self, 50, 0, 1, alignX, alignY, 1.6);
		self.huds["velocity"]["average"].hidewheninmenu = true;
		self.huds["velocity"]["average"].archived = false;
		self.huds["velocity"]["average"].label = &"^3A ^7&&1";
		self.huds["velocity"]["average"] setValue(0);
	}
	if (self.settings["hud_velocity_info"] >= 2)
	{
		self.huds["velocity"]["max"] = addHud(self, 100, 0, 1, alignX, alignY, 1.6);
		self.huds["velocity"]["max"].hidewheninmenu = true;
		self.huds["velocity"]["max"].archived = false;
		self.huds["velocity"]["max"].label = &"^1M ^7&&1";
		self.huds["velocity"]["max"] setValue(0);
	}
}

updateVelocity(player)
{
	if (!isDefined(self.huds["velocity"]))
		return;

	self.huds["velocity"]["value"] setValue(player.velocityDist);

	if (self.settings["hud_velocity_ground"] == 1)
		self.huds["velocity"]["ground"] setValue(player.groundTime);

	if (isDefined(player.vels) && player.vels.size)
	{
		if (self.settings["hud_velocity_info"] >= 1)
		self.huds["velocity"]["average"] setValue(int(Average(player.vels)));
		if (self.settings["hud_velocity_info"] >= 2)
			self.huds["velocity"]["max"] setValue(int(GetMax(player.vels)));
	}
	if (isDefined(player.groundTimes) && player.groundTimes.size)
	{
		if (self.settings["hud_velocity_ground"] == 2)
			self.huds["velocity"]["ground"] setValue(int(Average(player.groundTimes)));
	}
}

clear()
{
	if (isDefined(self.huds["velocity"]))
	{
		keys = getArrayKeys(self.huds["velocity"]);
		for (i = 0; i < keys.size; i++)
		{
			if (isDefined(self.huds["velocity"][keys[i]]))
				self.huds["velocity"][keys[i]] destroy();
		}
	}
}

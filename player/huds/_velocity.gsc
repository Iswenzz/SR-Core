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

	self clear();
	
    if (!self.settings["hud_spectator"] || !self.settings["hud_velocity"])
        return;

	self hudVelocity();

    self.vels = [];
    self.prevVelocityDist = self getPlayerVelocity();
    self.prevOnGround = self isOnGround();

	while (true)
	{
		player = IfUndef(self getSpectatorClient(), self);

        self.velocityDist = self getPlayerVelocity();
        self.onGround = self isOnGround();

        if (self.onGround && !self.prevOnGround)
            self.vels[self.vels.size] = self.prevVelocityDist;

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

	if (self.settings["hud_velocity_info"] >= 1)
	{
		self.huds["velocity"]["average"] = addHud(self, -50, 0, 1, alignX, alignY, 1.6);
		self.huds["velocity"]["average"].color = ToRGB(0, 255, 255);
		self.huds["velocity"]["average"].hidewheninmenu = true;
		self.huds["velocity"]["average"].archived = false;
	}
	if (self.settings["hud_velocity_info"] >= 2)
	{
		self.huds["velocity"]["max"] = addHud(self, 50, 0, 1, alignX, alignY, 1.6);
		self.huds["velocity"]["max"].color = ToRGB(0, 255, 0);
		self.huds["velocity"]["max"].hidewheninmenu = true;
		self.huds["velocity"]["max"].archived = false;
	}
}

updateVelocity(player)
{
	if (!isDefined(self.huds["velocity"]))
		return;

	self.huds["velocity"]["value"] setValue(player.velocityDist);

	if (!isDefined(player.vels) || !player.vels.size)
		return;

	if (self.settings["hud_velocity_info"] >= 1)
		self.huds["velocity"]["average"] setValue(int(Average(player.vels)));
	if (self.settings["hud_velocity_info"] >= 2)
		self.huds["velocity"]["max"] setValue(int(GetMax(player.vels)));
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

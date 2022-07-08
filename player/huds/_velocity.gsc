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

    if (!self.settings["hud_velocity"])
        return;

	wait 0.05;

	self clear();
	self hudVelocity();
	self vars();

	while (true)
	{
		player = IfUndef(self getSpectatorClient(), self);

		if (player isNewRun(self.run))
			self vars();

		self.run = player.run;
        self.velocityDist = player getPlayerVelocity();
        self.onGround = player isOnGround();

        if (self.onGround && !self.prevOnGround)
        {
			self.vels[self.vels.size] = self.prevVelocityDist;
			self.groundTimes[self.groundTimes.size] = self.groundTime;
			self.groundTime = 0;
		}
		if (self.onGround)
			self.groundTime += 50;

		self updateVelocity();

		wait 0.05;

        self.prevVelocityDist = self.velocityDist;
        self.prevOnGround = self.onGround;
	}
}

vars()
{
	self.vels = [];
	self.groundTime = 0;
	self.groundTimes = [];
    self.prevVelocityDist = 0;
    self.prevOnGround = true;
}

getPosition()
{
	position = spawnStruct();
	position.x = 0;
	position.y = 0;

	horizontal = getHorizontal(self.settings["hud_velocity"]);
	vertical = getVertical(self.settings["hud_velocity"]);

	if (horizontal == "left")
	{
		position.x = 50;
		if (vertical == "top")
			position.y = 100;
	}
	if (horizontal == "right")
	{
		position.x = -100;
		if (vertical == "top")
			position.y = 35;
		if (vertical == "bottom")
			position.y = -15;
	}
	if (vertical == "middle")
		position.y = 30;
	return position;
}

hudVelocity()
{
	position = self getPosition();
	alignX = getHorizontal(self.settings["hud_velocity"]);
	alignY = getVertical(self.settings["hud_velocity"]);

	self.huds["velocity"] = [];
	self.huds["velocity"]["value"] = addHud(self, 0, 0, 1, alignX, alignY, 1.6);
	self.huds["velocity"]["value"].hidewheninmenu = true;
	self.huds["velocity"]["value"].archived = false;
	self.huds["velocity"]["value"].label = &"^5V ^7&&1";
	self.huds["velocity"]["value"].x += position.x;
	self.huds["velocity"]["value"].y += position.y;

	if (self.settings["hud_velocity_ground"])
	{
		self.huds["velocity"]["ground"] = addHud(self, -50, 0, 1, alignX, alignY, 1.6);
		self.huds["velocity"]["ground"].hidewheninmenu = true;
		self.huds["velocity"]["ground"].archived = false;
		self.huds["velocity"]["ground"].label = &"^2G ^7&&1";
		self.huds["velocity"]["ground"] setValue(0);
		self.huds["velocity"]["ground"].x += position.x;
		self.huds["velocity"]["ground"].y += position.y;
	}
	if (self.settings["hud_velocity_info"] >= 1)
	{
		self.huds["velocity"]["average"] = addHud(self, 50, 0, 1, alignX, alignY, 1.6);
		self.huds["velocity"]["average"].hidewheninmenu = true;
		self.huds["velocity"]["average"].archived = false;
		self.huds["velocity"]["average"].label = &"^3A ^7&&1";
		self.huds["velocity"]["average"] setValue(0);
		self.huds["velocity"]["average"].x += position.x;
		self.huds["velocity"]["average"].y += position.y;
	}
	if (self.settings["hud_velocity_info"] >= 2)
	{
		self.huds["velocity"]["max"] = addHud(self, 100, 0, 1, alignX, alignY, 1.6);
		self.huds["velocity"]["max"].hidewheninmenu = true;
		self.huds["velocity"]["max"].archived = false;
		self.huds["velocity"]["max"].label = &"^1M ^7&&1";
		self.huds["velocity"]["max"] setValue(0);
		self.huds["velocity"]["max"].x += position.x;
		self.huds["velocity"]["max"].y += position.y;
	}
}

updateVelocity()
{
	if (isDefined(self.huds["velocity"]))
		self.huds["velocity"]["value"] setValue(self.velocityDist);

	if (isDefined(self.huds["velocity"]["ground"]) && self.settings["hud_velocity_ground"] == 1)
		self.huds["velocity"]["ground"] setValue(self.groundTime);

	if (isDefined(self.vels) && self.vels.size)
	{
		if (isDefined(self.huds["velocity"]["average"]) && self.settings["hud_velocity_info"] >= 1)
			self.huds["velocity"]["average"] setValue(int(Average(self.vels)));
		if (isDefined(self.huds["velocity"]["max"]) && self.settings["hud_velocity_info"] >= 2)
			self.huds["velocity"]["max"] setValue(int(GetMax(self.vels)));
	}
	if (isDefined(self.groundTimes) && self.groundTimes.size)
	{
		if (isDefined(self.huds["velocity"]["ground"]) && self.settings["hud_velocity_ground"] == 2)
			self.huds["velocity"]["ground"] setValue(int(Average(self.groundTimes)));
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

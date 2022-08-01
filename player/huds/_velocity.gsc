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

	wait 0.1;

	self clear();
	self hudVelocity();
	self vars();

	while (true)
	{
		self.player = IfUndef(self getSpectatorClient(), self);

		if (isDefined(self.run) && self.player isNewRun(self.run))
			self vars();

		self.run = self.player.run;
        self.velocityDist = self.player getPlayerVelocity();
        self.onGround = self.player isOnGround();

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

	self.huds["velocity"] = addHud(self, 0, 0, 1, alignX, alignY, 1.6);
	self.huds["velocity"].x += position.x;
	self.huds["velocity"].y += position.y;
}

// @TODO
updateVelocity()
{
	if (!isDefined(self.huds["velocity"]))
		return;

	velocity = fmt("^5V ^7%d", self.velocityDist);
	ground = "";
	average = "";
	max = "";

	if (self.settings["hud_velocity_ground"] == 1)
		ground = fmt("^2G ^7%d", self.groundTime);
	if (isDefined(self.vels) && self.vels.size)
	{
		if (self.settings["hud_velocity_info"] >= 1)
			average = fmt("^3A ^7%d", int(Average(self.vels)));
		if (self.settings["hud_velocity_info"] >= 2)
			max = fmt("^1M ^7%d", int(GetMax(self.vels)));
	}
	if (isDefined(self.groundTimes) && self.groundTimes.size)
	{
		if (self.settings["hud_velocity_ground"] == 2)
			ground = fmt("^2G ^7%d", int(Average(self.groundTimes)));
	}
	self.huds["velocity"] setText(fmt("%s    %s    %s    %s", ground, velocity, average, max));
}

clear()
{
	if (isDefined(self.huds["velocity"]))
		self.huds["velocity"] destroy();
}

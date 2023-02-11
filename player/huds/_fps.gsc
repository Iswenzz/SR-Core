#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

main()
{
	precacheShader("fps_20");
	precacheShader("fps_30");
	precacheShader("fps_125");
	precacheShader("fps_142");
	precacheShader("fps_166");
	precacheShader("fps_250");
	precacheShader("fps_333");
	precacheShader("fps_500");
	precacheShader("fps_1000");

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
	self hudFps();
	self vars();

	while (true)
	{
		self.player = IfUndef(self getSpectatorClient(), self);

		if (self.player isNewRun(self.run))
			self vars();

		self.run = self.player.run;
        self.fps = self.player getPlayerFPS();
        self.isOnGround = self.player isOnGround();
        self.isBouncing = self.player isBouncing();

		self updateFps();

		wait 0.05;

        self.prevFps = self.fps;
        self.prevIsOnGround = self.isOnGround;
		self.prevIsBouncing = self.isBouncing;
	}
}

vars()
{
	self.fpsCombo = "";
	self.isBouncing = false;
    self.prevFps = 0;
    self.prevIsOnGround = true;
	self.prevIsBouncing = false;
}

hudFps()
{
	self.huds["fps"] = addHud(self, -15, -26, 1, "right", "bottom", 1.8);

    if (self.settings["hud_fps_combo"])
        self.huds["fps_combo"] = addHud(self, 150, 80, 0.8, "center", "middle", 1.4);
}

updateFps()
{
	if (isDefined(self.huds["fps"]) && self.fps != self.prevFps)
	{
		switch (self.fps)
		{
			case 20:
			case 30:
			case 125:
			case 142:
			case 166:
			case 250:
			case 333:
			case 500:
			case 1000:
				self.huds["fps"] setShader("fps_" + self.fps, 90, 60);
				break;
		}
	}
    if (!isDefined(self.huds["fps_combo"]))
        return;

    if (self.isOnGround)
    {
        if (self.fpsCombo.size)
		{
			self.fpsCombo = "";
       		self.huds["fps_combo"] setText(self.fpsCombo);
		}
        return;
    }
	if (self.isBouncing && !self.prevIsBouncing && self.fpsCombo.size)
	{
		self.fpsCombo += "-";
		self.prevFps = -1;
	}
	if (self.fps != self.prevFps || !self.fpsCombo.size)
	{
		if (self.fpsCombo.size > 400)
			return;
		switch (self.fps)
		{
			case 20:	self.fpsCombo += "(20)";	break;
			case 30:	self.fpsCombo += "(30)";	break;
			case 125:	self.fpsCombo += "1";		break;
			case 142:	self.fpsCombo += "4";		break;
			case 166:	self.fpsCombo += "6";		break;
			case 200:	self.fpsCombo += "(200)";	break;
			case 250:	self.fpsCombo += "2";		break;
			case 333:	self.fpsCombo += "3";		break;
			case 500:	self.fpsCombo += "5";		break;
			case 1000: 	self.fpsCombo += "0";		break;
		}
		self.huds["fps_combo"] setText(self.fpsCombo);
	}
}

isBouncing()
{
    if (self.isOnGround)
        return false;
    return !self getJumpOrigin();
}

clear()
{
	if (isDefined(self.huds["fps"]))
		self.huds["fps"] destroy();
	if (isDefined(self.huds["fps_combo"]))
		self.huds["fps_combo"] destroy();
}

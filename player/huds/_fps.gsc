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
	self endon("death");
	self endon("disconnect");
	self endon("joined_spectators");

    if (!self.settings["hud_spectator"])
        return;

	self clear();
	self hudFps();

	self.fpsCombo = "";
    self.prevFps = 0;
    self.prevIsOnGround = self isOnGround();
    self.prevIsFalling = false;

	while (true)
	{
		player = IfUndef(self getSpectatorClient(), self);

        self.fps = self getFPS();
        self.velocity = self getVelocity();
        self.isOnGround = self isOnGround();
        self.isFalling = self isFalling();

		self updateFps(player);
		
		wait 0.05;

        self.prevFps = self.fps;
        self.prevIsOnGround = self.isOnGround;
        self.prevIsFalling = self.isFalling;
	}
}

hudFps()
{
	self.huds["fps"] = addHud(self, -15, -26, 1, "right", "bottom", 1.8);
	self.huds["fps"].hidewheninmenu = true;
	self.huds["fps"].archived = false;

    if (self.settings["hud_fps_combo"])
    {
        self.huds["fps_combo"] = addHud(self, 150, 80, 0.8, "center", "middle", 1.4);
        self.huds["fps_combo"].hidewheninmenu = true;
        self.huds["fps_combo"].archived = false;
    }
}

updateFps(player)
{
	if (!isDefined(self.huds["fps"]))
		return;

	switch (player.fps)
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
			self.huds["fps"] setShader("fps_" + player.fps, 90, 60);
			break;
	}
    if (!isDefined(self.huds["fps_combo"]))
        return;

    if (self.isOnGround)
    {
        self.fpsCombo = "";
        self.huds["fps_combo"] setText(player.fpsCombo);
        return;
    }

	bounced = false;
    if (!self.isOnGround && !self.isFalling && self.prevIsFalling)
	{
		self.fpsCombo += "-";
		bounced = true;
	}
    if (!bounced && self.fps == self.prevFps && !self.prevIsOnGround)
        return;

	switch (self.fps)
	{
		case 20:	self.fpsCombo += "(20)";	break;
		case 30:	self.fpsCombo += "(30)";	break;
		case 125:	self.fpsCombo += "1";		break;
		case 142:	self.fpsCombo += "4";		break;
		case 166:	self.fpsCombo += "6";		break;
		case 250:	self.fpsCombo += "2";		break;
		case 333:	self.fpsCombo += "3";		break;
		case 500:	self.fpsCombo += "5";		break;
		case 1000: 	self.fpsCombo += "0";		break;
	}
	self.huds["fps_combo"] setText(player.fpsCombo);
}

isFalling()
{
    if (self.isOnGround)
        return false;
    if (self.velocity[2] >= 0)
        return false;
    return true;
}

clear()
{
	if (isDefined(self.huds["fps"]))
		self.huds["fps"] destroy();
	if (isDefined(self.huds["fps_combo"]))
		self.huds["fps_combo"] destroy();
}

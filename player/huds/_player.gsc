#include sr\sys\_events;
#include sr\utils\_hud;
#include sr\utils\_common;

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
	event("death", ::clear);
}

hud()
{
	self endon("death");
	self endon("disconnect");
	self endon("joined_spectators");

	if (self.isBot)
		return;

	self hudFps();

	while (self.sessionstate != "spectator")
	{
		wait 0.05;

		self updateFps();
		self updateVelocity();
	}
}

hudFps()
{
	self.huds["fps"] = [];
	self.huds["fps"] = addHud(self, -15, -26, 1, "right", "bottom", 1.8);
	self.huds["fps"].archived = false;
	self.huds["fps"].horzAlign = "right";
    self.huds["fps"].vertAlign = "bottom";
	self.huds["fps"].hidewheninmenu = true;

	if (self.settings["hud_velocity"])
	{
		self.huds["velocity"] = [];
		self.huds["velocity"] = addHud(self, 0, 0, 1,
			getHorizontal(self.settings["hud_velocity"]),
			getVertical(self.settings["hud_velocity"]), 1.6);
		self.huds["velocity"].archived = false;
		self.huds["velocity"].horzAlign = getHorizontal(self.settings["hud_velocity"]);
		self.huds["velocity"].vertAlign = getVertical(self.settings["hud_velocity"]);
		self.huds["velocity"].hidewheninmenu = true;
	}
}

updateFps()
{
	fps = self getFPS();

	switch (fps)
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
			self.huds["fps"] setShader("fps_" + fps, 90, 60);
			break;
	}
}

updateVelocity()
{
	self.huds["velocity"] setValue(self getPlayerVelocity());
}

clear()
{
	if (isDefined(self.huds["fps"]))
		self.huds["fps"] destroy();
	if (isDefined(self.huds["velocity"]))
		self.huds["velocity"] destroy();
}

#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

main()
{
	precacheShader("crosshair");

	event("spawn", ::hud);
	event("death", ::clear);
}

hud()
{
	self endon("death");
	self endon("disconnect");
	self endon("joined_spectators");

    if (self.settings["hud_crosshair"] < 2)
		return;

	wait 0.05;

	self clear();
	self hudCrosshair();
}

hudCrosshair()
{
	self.huds["crosshair"] = addHud(self, 0, 0, 1, "center", "middle", 1.4, 999);
	self.huds["crosshair"] setShader("crosshair", 2, 2);
}

clear()
{
	if (isDefined(self.huds["crosshair"]))
		self.huds["crosshair"] destroy();
}

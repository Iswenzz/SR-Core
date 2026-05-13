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
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

    if (self.settings["hud_crosshair"] < 2)
		return;

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

#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

main()
{
	precacheShader("arrow_w");
	precacheShader("arrow_a");
	precacheShader("arrow_s");
	precacheShader("arrow_d");

	event("spawn", ::hud);
	event("spectator", ::hud);
	event("death", ::clear);
}

hud()
{
	self endon("death");
	self endon("disconnect");
	self endon("joined_spectators");

    if (!self shouldRender())
		return;

	wait 0.3;

	self clear();
	self hudKeys();

	while (self shouldRender())
	{
		self.player = IfUndef(self getSpectatorClient(), self);

		self updateKeys();
		wait 0.05;
	}
}

shouldRender()
{
    if (self.sessionstate != "spectator" && !self.settings["hud_keys"])
    {
        self clear();
        return false;
    }
    return true;
}

hudKeys()
{
	self.huds["keys"] = [];
	self.huds["keys"][0] = addHud(self, 0, -20, 0, "center", "middle", 1.4, 2000);
	self.huds["keys"][0] setShader("arrow_w", 10, 10);
	self.huds["keys"][1] = addHud(self, -12, -10, 0, "center", "middle", 1.4, 2000);
	self.huds["keys"][1] setShader("arrow_a", 12, 8);
	self.huds["keys"][2] = addHud(self, 0, -9, 0, "center", "middle", 1.4, 2000);
	self.huds["keys"][2] setShader("arrow_s", 10, 10);
	self.huds["keys"][3] = addHud(self, 12, -10, 0, "center", "middle", 1.4, 2000);
	self.huds["keys"][3] setShader("arrow_d", 12, 8);
}

updateKeys()
{
	if (!isDefined(self.huds["keys"]) || !self.huds["keys"].size)
		return;

	self.huds["keys"][0].alpha = Ternary(self.player forwardButtonPressed(), 1, 0);
	self.huds["keys"][1].alpha = Ternary(self.player moveLeftButtonPressed(), 1, 0);
	self.huds["keys"][2].alpha = Ternary(self.player backButtonPressed(), 1, 0);
	self.huds["keys"][3].alpha = Ternary(self.player moveRightButtonPressed(), 1, 0);
}

clear()
{
	if (isDefined(self.huds["keys"]))
	{
		for (i = 0; i < self.huds["keys"].size; i++)
		{
			if (isDefined(self.huds["keys"][i]))
				self.huds["keys"][i] destroy();
		}
	}
}

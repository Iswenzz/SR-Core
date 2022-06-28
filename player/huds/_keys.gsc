#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

main()
{
	precacheShader("key_w");
	precacheShader("key_a");
	precacheShader("key_s");
	precacheShader("key_d");

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

	self clear();
	self hudKeys();

	while (self shouldRender())
	{
		player = IfUndef(self getSpectatorClient(), self);

		self updateKeys(player);
		wait 0.05;
	}
}

shouldRender()
{
    if (!self.settings["hud_spectator"] || self.sessionstate != "spectator")
    {
        self clear();
        return false;
    }
    return true;
}

hudKeys()
{
	self.huds["keys"] = [];
	self.huds["keys"][0] = addHud(self, 0, -120, 0.6, "center", "bottom", 1.8);
	self.huds["keys"][0] setShader("key_w", 30, 30);
	self.huds["keys"][0].archived = false;
	self.huds["keys"][0].hidewheninmenu = true;

	self.huds["keys"][1] = addHud(self, -35, -85, 0.6, "center", "bottom", 1.8);
	self.huds["keys"][1] setShader("key_a", 30, 30);
	self.huds["keys"][1].archived = false;
	self.huds["keys"][1].hidewheninmenu = true;

	self.huds["keys"][2] = addHud(self, 0, -85, 0.6, "center", "bottom", 1.8);
	self.huds["keys"][2] setShader("key_s", 30, 30);
	self.huds["keys"][2].archived = false;
	self.huds["keys"][2].hidewheninmenu = true;

	self.huds["keys"][3] = addHud(self, 35, -85, 0.6, "center", "bottom", 1.8);
	self.huds["keys"][3] setShader("key_d", 30, 30);
	self.huds["keys"][3].archived = false;
	self.huds["keys"][3].hidewheninmenu = true;
}

updateKeys(player)
{
	if (!isDefined(self.huds["keys"]))
		return;

	self.huds["keys"][0].alpha = Ternary(player forwardButtonPressed(), 1, 0.6);
	self.huds["keys"][1].alpha = Ternary(player moveLeftButtonPressed(), 1, 0.6);
	self.huds["keys"][2].alpha = Ternary(player backButtonPressed(), 1, 0.6);
	self.huds["keys"][3].alpha = Ternary(player moveRightButtonPressed(), 1, 0.6);
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

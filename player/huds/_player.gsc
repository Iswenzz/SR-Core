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

	self clear();
	self hudFps();
	self hudVelocity();
	self hudKeys();

	while (true)
	{
		player = IfUndef(self getSpectatorClient(), self);

		if (!isDefined(player))
		{
			wait 0.05;
			continue;
		}
		if (player != self && !self.settings["hud_spectator"])
		{
			self clear();
			break;
		}		

		self updateFps(player);
		self updateVelocity(player);
		self updateKeys(player);
		
		wait 0.05;
	}
}

hudFps()
{
	self.huds["fps"] = addHud(self, -15, -26, 1, "right", "bottom", 1.8);
	self.huds["fps"].hidewheninmenu = true;
	self.huds["fps"].archived = true;
}

hudVelocity()
{
	if (!self.settings["hud_velocity"])
		return;

	self.vels = [];
	self.prevVelocity = 0;
	self.prevOnGround = true;

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

hudKeys()
{
	if (self.sessionstate != "spectator")
		return;

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
	if (!isDefined(self.huds["keys"]) || !self.huds["keys"].size || self.sessionstate != "spectator")
		return;

	self.huds["keys"][0].alpha = Ternary(player forwardButtonPressed(), 1, 0.6);
	self.huds["keys"][1].alpha = Ternary(player moveLeftButtonPressed(), 1, 0.6);
	self.huds["keys"][2].alpha = Ternary(player backButtonPressed(), 1, 0.6);
	self.huds["keys"][3].alpha = Ternary(player moveRightButtonPressed(), 1, 0.6);
}

updateFps(player)
{
	fps = player getFPS();

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

updateVelocity(player)
{
	if (!isDefined(self.huds["velocity"]))
		return;

	if (self isOnGround() && !self.prevOnGround)
		self.vels[self.vels.size] = self.prevVelocity;
	self.prevVelocity = self getPlayerVelocity();
	self.prevOnGround = self isOnGround();

	self.huds["velocity"]["value"] setValue(player getPlayerVelocity());

	if (!isDefined(player.vels) || !player.vels.size)
		return;

	if (self.settings["hud_velocity_info"] >= 1)
		self.huds["velocity"]["average"] setValue(int(Average(player.vels)));
	if (self.settings["hud_velocity_info"] >= 2)
		self.huds["velocity"]["max"] setValue(int(GetMax(player.vels)));
}

clear()
{
	if (isDefined(self.huds["fps"]))
		self.huds["fps"] destroy();
	if (isDefined(self.huds["velocity"]))
	{
		keys = getArrayKeys(self.huds["velocity"]);
		for (i = 0; i < keys.size; i++)
		{
			if (isDefined(self.huds["velocity"][keys[i]]))
				self.huds["velocity"][keys[i]] destroy();
		}
	}
	if (isDefined(self.huds["keys"]))
	{
		for (i = 0; i < self.huds["keys"].size; i++)
		{
			if (isDefined(self.huds["keys"][i]))
				self.huds["keys"][i] destroy();
		}
	}
}

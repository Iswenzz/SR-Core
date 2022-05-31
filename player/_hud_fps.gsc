hud()
{
	self endon("disconnect");
	self notify("fpshud_end");
	self endon("fpshud_end");

	self.check_ele = false;
	self.check_lowfps = false;

	if(self.isBot)
		return;

	wait 0.05;

	while(1)
	{
		if(isDefined(self.pers["team"]) && self.pers["team"] == "spectator" || self.sessionstate == "spectator")
		{
			self thread hide_fps_hud();
			self on_spawn_show_fps_hud();
			break;
		}

		if(!isDefined(self.fpshud))
			self thread fpsHud_playing();

		self.real_fps = self getCountedFPS();

		if(self.sessionstate == "playing" && self.real_fps < 1 && !self.check_lowfps)
			self thread check_lowfps();

		vel = getPlayerVelocity();
		if (isDefined(self.velocity_hud))
			self.velocity_hud setValue(vel);

		if(self.sessionstate == "playing" && !self.check_ele)
			self thread check_ele();

		fps = self getuserinfo("com_maxfps");
		self.current_fps = ""+fps;

		if(!isDefined(fps))
			continue;

		switch(fps)
		{
			case "20":
			case "30":
			case "125":
			case "142":
			case "166":
			case "250":
			case "333":
			case "500":
			case "1000":
				self.fpshud SetShader("fps_"+fps, 90, 60);
				break;
		}

		wait 0.05;
	}
}

getPlayerVelocity()
{
    velocity = self getVelocity();
    self.real_velocity = velocity;
    return int(sqrt((velocity[0]*velocity[0])+(velocity[1]*velocity[1])));
}

on_spawn_show_fps_hud()
{
	self waittill("spawned_player");

	self thread show_fps_hud();
}

hide_fps_hud()
{
	if(isDefined(self.fpshud))
		self.fpshud Destroy();

	if(isDefined(self.velocity_hud))
		self.velocity_hud Destroy();

	self.fpshud = undefined;
	self.velocity_hud = undefined;
}

fpsHud_playing()
{
	self.fpshud = addhud(self, -15, -26, 1, "right", "bottom", 1.8 );
	self.fpshud.archived = false;
	self.fpshud.horzAlign = "right";
    self.fpshud.vertAlign = "bottom";
	self.fpshud.hidewheninmenu = true;

	if (self.settings["hud_velocity"] != 0)
	{
		self.velocity_hud = addhud(self, 0, 0, 1, getHorizontal(self.settings["hud_velocity"]), getVertical(self.settings["hud_velocity"]), 1.6 );
		self.velocity_hud.archived = false;
		self.velocity_hud.horzAlign = getHorizontal(self.settings["hud_velocity"]);
		self.velocity_hud.vertAlign = getVertical(self.settings["hud_velocity"]);
		self.velocity_hud.hidewheninmenu = true;
	}
}

getVertical(int)
{
	switch (int)
	{
		case 1:
		case 2:
		case 3:
			return "top";

		case 4:
		case 5:
		case 6:
			return "bottom";

		default:
			return "bottom";
	}
}

getHorizontal(int)
{
	switch (int)
	{
		case 1:
		case 4:
			return "left";

		case 2:
		case 5:
			return "center";

		case 3:
		case 6:
			return "right";

		default:
			return "left";
	}
}

addHud( who, x, y, alpha, alignX, alignY, fontScale )
{
	if( isPlayer( who ) )
		hud = newClientHudElem( who );
	else
		hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.alignX = alignX;
	hud.alignY = alignY;
	hud.fontScale = fontScale;
	return hud;
}

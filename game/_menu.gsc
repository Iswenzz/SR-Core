init()
{
	level.sr_menu = [];

	precacheShader("ui_host");
	precacheShader("line_vertical");
	precacheShader("nightvision_overlay_goggles");
	precacheShader("hud_arrow_left");
}

onMenuResponse(id, weapon)
{
	self endon("disconnect");
	self.sr_menu_open = false;

	for (;;)
	{
		if (!isDefined(self))
			break;

		currentWeapon = self GetCurrentWeapon();
		if (!self.sr_menu_open && currentWeapon == weapon)
		{
			if (self.sessionstate != "playing" || self.pers["team"] == "spectator")
				continue;

			self.sr_menu_open = true;
			self notify("sr_menu_open");

			for (; self.sessionstate == "playing" && !self isOnGround();)
				wait .05;

			self open(id);

			self allowSpectateTeam("allies", false);
			self allowSpectateTeam("axis", false);
			self allowSpectateTeam("none", false);
			wait 1.3;
		}
		else if (self meleeButtonPressed())
			self close();

		wait 0.2;
	}
}

close()
{
	self notify("sr_menu_close");
	self takeWeapon("shop_mp");

	if (!isDefined(self.sr_menu))
		return;

	for (i = 0; i < self.sr_menu.size; i++)
	{
		if (isDefined(self.sr_menu[i]))
			self.sr_menu[i] thread fadeOut(1, true, "right");
	}

	self.sr_menu_open = false;

	self switchToWeapon(self.pers["weapon"]);

	self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("none", true);

	wait 0.5;

	self giveWeapon("shop_mp");
}

option(section, name, script, arg)
{
	id = section.id;
	menu = section.name;

	predator = IfUndef(level.sr_menu[id][menu], []);
	predator[predator.size] = name;
	predator[predator.size] = script;
	predator[predator.size] = arg;

	level.sr_menu[id][menu] = predator;
}

menu(name, id, script)
{
	menu = "main";

	section = spawnStruct();
	section.name = name;
	section.id = id;
	section.script = script;

	option(name, id, menu, script);
	return section;
}

getMenuOptions(id, menu)
{
	options = "";
	for(i = 0; i < level.sr_menu[id][menu].size; i++)
		options += level.sr_menu[id][menu][i] + "\n";
	return options;
}

open(id)
{
	self endon("sr_menu_close");
	self endon("disconnect");
	self endon("death");

	submenu = "main";
	menu = level.sr_menu[id][submenu];

	self.sr_menu[0] = addTextHud(self, -200, 0, .6, "left", "top", "right",0, 101);
	self.sr_menu[0] setShader("nightvision_overlay_goggles", 400, 650);
	self.sr_menu[0] thread fadeIn(.5, true, "right");

	self.sr_menu[1] = addTextHud(self, -200, 0, .5, "left", "top", "right", 0, 101);
	self.sr_menu[1] setShader("black", 400, 650);
	self.sr_menu[1] thread fadeIn(.5, true, "right");

	self.sr_menu[2] = addTextHud(self, -200, 89, .5, "left", "top", "right", 0, 102);
	self.sr_menu[2] setShader("line_vertical", 600, 22);
	self.sr_menu[2] thread fadeIn(.5, true, "right");

	self.sr_menu[3] = addTextHud(self, -190, 93, 1, "left", "top", "right", 0, 104);
	self.sr_menu[3] setShader("ui_host", 14, 14);
	self.sr_menu[3] thread fadeIn(.5, true, "right");

	self.sr_menu[4] = addTextHud(self, -165, 100, 1, "left", "middle", "right", 1.4, 103);
	self.sr_menu[4] setText(getMenuOptions(id, submenu));
	self.sr_menu[4] thread fadeIn(.5, true, "right");

	self.sr_menu[5] = addTextHud(self, -170, 400, 1, "left", "middle", "right" ,1.4, 103);
	self.sr_menu[5] setText("Select: [Right or Left Mouse]\nUse: [[{+activate}]]\nLeave: [[{+melee}]]");
	self.sr_menu[5] thread fadeIn(.5, true, "right");

	for (selected = 0; !self meleeButtonPressed(); wait .05)
	{
		if (self attackButtonPressed())
		{
			self playLocalSound("mouse_over");
			selected = Ternary(selected == menu.size - 1, 0, selected + 1);
		}
		if (self adsButtonPressed())
		{
			self sr\utils\_common::clientCmd("-speed_throw");
			self playLocalSound("mouse_over");
			selected = Ternary(selected == 0,  menu.size - 1, selected - 1);
		}
		if (self adsButtonPressed() || self attackButtonPressed())
		{
			if(submenu == "main")
			{
				self.sr_menu[2] moveOverTime(.05);
				self.sr_menu[2].y = 89 + (16.8 * selected);
				self.sr_menu[3] moveOverTime(.05);
				self.sr_menu[3].y = 93 + (16.8 * selected);
			}
			else
			{
				self.sr_menu[7] moveOverTime(.05);
				self.sr_menu[7].y = 10 + self.sr_menu[6].y + (16.8 * selected);
			}
		}
		if ((self adsButtonPressed() || self attackButtonPressed()) && !self useButtonPressed())
			wait .15;

		if (self useButtonPressed())
		{
			// Combo box
			if (isString(menu[selected + 1]))
			{
				abstand = (16.8 * selected);
				submenu = menu[selected + 1];

				self.sr_menu[6] = addTextHud( self, -430, abstand + 50, .5, "left", "top", "right", 0, 101 );
				self.sr_menu[6] setShader("black", 200, 300);
				self.sr_menu[6] thread fadeIn(.5, true, "left");

				self.sr_menu[7] = addTextHud( self, -430, abstand + 60, .5, "left", "top", "right", 0, 102 );
				self.sr_menu[7] setShader("line_vertical", 200, 22);
				self.sr_menu[7] thread fadeIn(.5, true, "left");

				self.sr_menu[8] = addTextHud( self, -219, 93 + (16.8 * selected), 1, "left", "top", "right", 0, 104 );
				self.sr_menu[8] setShader("hud_arrow_left", 14, 14);
				self.sr_menu[8] thread fadeIn(.5, true, "left");

				self.sr_menu[9] = addTextHud( self, -420, abstand + 71, 1, "left", "middle", "right", 1.4, 103 );
				self.sr_menu[9] setText(getMenuOptions(id, submenu));
				self.sr_menu[9] thread fadeIn(.5, true, "left");

				selected = 0;
				wait 0.2;
			}
			else
				self [[menu[selected + 1]]](menu[selected + 1]);
		}
	}
	self thread close();
}

addTextHud(who, x, y, alpha, alignX, alignY, vert, fontScale, sort)
{
	if (isPlayer(who) )
		hud = newClientHudElem(who);
	else
		hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.alignX = alignX;
	hud.alignY = alignY;
	if (isDefined(vert))
		hud.horzAlign = vert;
	if (fontScale != 0)
		hud.fontScale = fontScale;
	return hud;
}

fadeOut(time, slide, dir)
{
	if (!isDefined(self))
		return;
	if (isDefined(slide) && slide)
	{
		self moveOverTime(0.2);
		if (isDefined(dir) && dir == "right")
			self.x += 600;
		else
			self.x -= 600;
	}
	self fadeOverTime(time);
	self.alpha = 0;

	wait time;
	if (isDefined(self))
		self destroy();
}

fadeIn(time, slide, dir)
{
	if (!isDefined(self))
		return;
	if (isDefined(slide) && slide)
	{
		if(isDefined(dir) && dir == "right")
			self.x += 600;
		else
			self.x -= 600;

		self moveOverTime(.2);

		if (isDefined(dir) && dir == "right")
			self.x -= 600;
		else
			self.x += 600;
	}
	alpha = self.alpha;
	self.alpha = 0;
	self fadeOverTime(time);
	self.alpha = alpha;
}

blur(start, end)
{
	self notify("newblur");
	self endon("newblur");

	start = start * 10;
	end = end * 10;

	self endon("disconnect");
	self endon("death");

	if (start <= end)
	{
		for (i = start; i < end; i++)
		{
			self setClientDvar("r_blur", i / 10);
			wait .05;
		}
	}
	else for(i = start; i >= end; i--)
	{
		self setClientDvar("r_blur", i / 10);
		wait .05;
	}
}

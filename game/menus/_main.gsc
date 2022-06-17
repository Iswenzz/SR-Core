#include sr\utils\_common;
#include sr\utils\_hud;

initMenus()
{
	level.huds["script_menu"] = [];

	precacheShader("ui_host");
	precacheShader("line_vertical");
	precacheShader("nightvision_overlay_goggles");
	precacheShader("hud_arrow_left");
}

menuEvent(id, weapon)
{
	self endon("disconnect");
	self.huds["script_menu"] = [];
	self.script_menu_open = false;

	while (true)
	{
		if (!isDefined(self))
			break;

		if (!self.script_menu_open && self GetCurrentWeapon() == weapon)
		{
			if (self.sessionstate != "playing" || self.pers["team"] == "spectator")
				continue;

			self.script_menu_open = true;
			self notify("sr_menu_open");

			while (self.sessionstate == "playing" && !self isOnGround())
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

	if (!isDefined(self.huds["script_menu"]))
		return;

	huds = getArrayKeys(self.huds["script_menu"]);
	for (i = 0; i < huds.size; i++)
	{
		if (isDefined(self.huds["script_menu"][huds[i]]))
			self.huds["script_menu"][huds[i]] thread fadeOut(1, "right");
	}

	self.script_menu_open = false;
	self switchToWeapon(self.pers["weapon"]);

	self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("none", true);

	wait 0.5;

	self giveWeapon("shop_mp");
}

menuOption(section, name, script, args)
{
	id = section.id;
	menu = section.script;

	if (!isDefined(level.huds["script_menu"][id][menu]))
		level.huds["script_menu"][id][menu] = [];
	index = level.huds["script_menu"][id][menu].size;

	option = spawnStruct();
	option.name = name;
	option.script = script;
	option.args = args;

	level.huds["script_menu"][id][menu][index] = option;
}

menuElement(name, id, script)
{
	menu = "main";

	if (!isDefined(level.huds["script_menu"][id]))
	{
		level.huds["script_menu"][id] = [];
		level.huds["script_menu"][id][menu] = [];
	}

	section = spawnStruct();
	section.id = id;
	section.name = name;
	section.script = script;

	if (script != menu)
	{
		index = level.huds["script_menu"][id][menu].size;
		level.huds["script_menu"][id][menu][index] = section;
	}
	return section;
}

getMenuOptions(id, menu)
{
	options = "";
	for (i = 0; i < level.huds["script_menu"][id][menu].size; i++)
		options += level.huds["script_menu"][id][menu][i].name + "\n";
	return options;
}

open(id)
{
	self endon("sr_menu_close");
	self endon("disconnect");
	self endon("death");

	submenu = "main";
	menus = level.huds["script_menu"][id];

	self.huds["script_menu"]["backround_night"] = addTextHud(self, -200, 0, .6, "left", "top", "right",0, 101);
	self.huds["script_menu"]["backround_night"] setShader("nightvision_overlay_goggles", 400, 650);
	self.huds["script_menu"]["backround_night"] thread fadeIn(.5, "right");

	self.huds["script_menu"]["backround"] = addTextHud(self, -200, 0, .5, "left", "top", "right", 0, 101);
	self.huds["script_menu"]["backround"] setShader("black", 400, 650);
	self.huds["script_menu"]["backround"] thread fadeIn(.5, "right");

	self.huds["script_menu"]["line"] = addTextHud(self, -200, 89, .5, "left", "top", "right", 0, 102);
	self.huds["script_menu"]["line"] setShader("line_vertical", 600, 22);
	self.huds["script_menu"]["line"] thread fadeIn(.5,"right");

	self.huds["script_menu"]["select"] = addTextHud(self, -190, 93, 1, "left", "top", "right", 0, 104);
	self.huds["script_menu"]["select"] setShader("ui_host", 14, 14);
	self.huds["script_menu"]["select"] thread fadeIn(.5, "right");

	self.huds["script_menu"]["options"] = addTextHud(self, -165, 100, 1, "left", "middle", "right", 1.4, 103);
	self.huds["script_menu"]["options"] setText(getMenuOptions(id, submenu));
	self.huds["script_menu"]["options"] thread fadeIn(.5, "right");

	self.huds["script_menu"]["help"] = addTextHud(self, -170, 400, 1, "left", "middle", "right" ,1.4, 103);
	self.huds["script_menu"]["help"] setText("^5Select: [Right or Left Mouse]\nUse: [[{+activate}]]\nLeave: [[{+melee}]]");
	self.huds["script_menu"]["help"] thread fadeIn(.5, "right");

	for (selected = 0; !self meleeButtonPressed(); wait .05)
	{
		if (self attackButtonPressed())
		{
			self playLocalSound("mouse_over");
			selected = Ternary(selected == menus[submenu].size - 1, 0, selected + 1);
		}
		if (self adsButtonPressed())
		{
			self clientCmd("-speed_throw");
			self playLocalSound("mouse_over");
			selected = Ternary(selected == 0,  menus[submenu].size - 1, selected - 1);
		}
		if (self adsButtonPressed() || self attackButtonPressed())
		{
			if (submenu == "main")
			{
				self.huds["script_menu"]["line"] moveOverTime(.05);
				self.huds["script_menu"]["line"].y = 89 + (16.8 * selected);
				self.huds["script_menu"]["select"] moveOverTime(.05);
				self.huds["script_menu"]["select"].y = 93 + (16.8 * selected);
			}
			else
			{
				self.huds["script_menu"]["submenu_line"] moveOverTime(.05);
				self.huds["script_menu"]["submenu_line"].y = 10 + self.huds["script_menu"]["submenu"].y + (16.8 * selected);
			}
		}
		if ((self adsButtonPressed() || self attackButtonPressed()) && !self useButtonPressed())
			wait .15;

		if (self useButtonPressed())
		{
			// Combo
			if (isString(menus[submenu][selected].script))
			{
				abstand = (16.8 * selected);
				submenu = menus[submenu][selected].script;

				self.huds["script_menu"]["submenu"] = addTextHud(self, -430, abstand + 50, .5, "left", "top", "right", 0, 101);
				self.huds["script_menu"]["submenu"] setShader("black", 200, 300);
				self.huds["script_menu"]["submenu"] thread fadeIn(.5, "left");

				self.huds["script_menu"]["submenu_line"] = addTextHud(self, -430, abstand + 60, .5, "left", "top", "right", 0, 102);
				self.huds["script_menu"]["submenu_line"] setShader("line_vertical", 200, 22);
				self.huds["script_menu"]["submenu_line"] thread fadeIn(.5, "left");

				self.huds["script_menu"]["submenu_arrow"] = addTextHud(self, -219, 93 + (16.8 * selected), 1, "left", "top", "right", 0, 104);
				self.huds["script_menu"]["submenu_arrow"] setShader("hud_arrow_left", 14, 14);
				self.huds["script_menu"]["submenu_arrow"] thread fadeIn(.5, "left");

				self.huds["script_menu"]["submenu_options"] = addTextHud(self, -420, abstand + 71, 1, "left", "middle", "right", 1.4, 103);
				self.huds["script_menu"]["submenu_options"] setText(getMenuOptions(id, submenu));
				self.huds["script_menu"]["submenu_options"] thread fadeIn(.5, "left");

				selected = 0;
				wait 0.2;

				continue;
			}
			self thread [[menus[submenu][selected].script]](menus[submenu][selected].args);
			submenu = "main";
			wait 0.2;
		}
	}
	self thread close();
}

addTextHud(who, x, y, alpha, alignX, alignY, vert, fontScale, sort)
{
	hud = addHud(who, x, y, alpha, alignX, alignY, fontScale, sort);
	hud.horzAlign = IfUndef(vert, "left");
	hud.vertAlign = "top";
	return hud;
}

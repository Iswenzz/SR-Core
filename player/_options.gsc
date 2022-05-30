/*

  _|_|_|            _|      _|      _|                  _|
_|        _|    _|    _|  _|        _|          _|_|    _|  _|_|_|_|
  _|_|    _|    _|      _|          _|        _|    _|  _|      _|
      _|  _|    _|    _|  _|        _|        _|    _|  _|    _|
_|_|_|      _|_|_|  _|      _|      _|_|_|_|    _|_|    _|  _|_|_|_|

Script made by SuX Lolz (Iswenzz) and Sheep Wizard

Steam: http://steamcommunity.com/profiles/76561198163403316/
Discord: https://discord.gg/76aHfGF
Youtube: https://www.youtube.com/channel/UC1vxOXBzEF7W4g7TRU0C1rw
Paypal: suxlolz@outlook.fr
Email Pro: suxlolz1528@gmail.com

*/

#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

#include braxi\_common;
#include braxi\_dvar;

#include sr\sys\_common;

init() { }

onConnectOptions()
{
	wait 0.05;

	path = "./sr/server_data/admin/player_options/" + self.playerID + ".txt";
	if(!checkfile(path)) // if new player, default settings
	{
		checkQueue();
		new = FS_Fopen(path, "write");
		FS_FClose(new);

		self.pers["crosshair"] = 1;
		self.pers["draw_fps"] = 1;
		self.pers["fullbright"] = 0;
		self.pers["draw_distance"] = 0;
		self.pers["fovscale"] = 1000;
		self.pers["xp_bar"] = 0;
		self.pers["spec_hud"] = 1;
		self.pers["velocity_metter"] = 4;
		self.pers["compass"] = 0;
		self.pers["hideplayers"] = 0;
		self.pers["draw2D"] = 1;
		self.pers["fxenabled"] = 1;
		self.pers["knifeonly"] = 0;
	}
	else
		self thread readOptions();

	self setClientDvar("cg_drawSpectatorMessages", "1");

	self setClientDvar("sr_setting_0", "Crosshair");
	self setClientDvar("sr_setting_1", "Draw FPS");
	self setClientDvar("sr_setting_2", "Fullbright");
	self setClientDvar("sr_setting_3", "XP Bar");
	self setClientDvar("sr_setting_4", "Spec HUD");
	self setClientDvar("sr_setting_5", "Draw Distance");
	self setClientDvar("sr_setting_6", "FOV Scale");
	self setClientDvar("sr_setting_7", "Velocity Metter");
	self setClientDvar("sr_setting_8", "Compass");
	self setClientDvar("sr_setting_9", "Hide Players");
	self setClientDvar("sr_setting_10", "Draw 2D");
	self setClientDvar("sr_setting_11", "FX");
	self setClientDvar("sr_setting_12", "Knife Only");

	self thread hidePlayers();
	self thread show_fps_hud();
	self thread updateSettings();
	self thread menuRes();
}

saveOptions()
{
	self endon("disconnect");

	self setStat(2630,int(self.pers["fovscale"]));
	self setStat(1600,self.pers["crosshair"]);
	self setStat(1601,self.pers["draw_fps"]);
	self setStat(1602,self.pers["fullbright"]);
	self setStat(1603,self.pers["draw_distance"]);
	self setStat(1605,self.pers["xp_bar"]);
	self setStat(1606,self.pers["spec_hud"]);
	self setStat(1607,self.pers["velocity_metter"]);
	self setStat(1608,self.pers["compass"]);
	self setStat(1609,self.pers["hideplayers"]);
	self setStat(1610,self.pers["draw2D"]);
	self setStat(1611,self.pers["fxenabled"]);
	self setStat(1612,self.pers["knifeonly"]);
}

readOptions()
{
	self.pers["fovscale"] = self getStat(2630);
	self.pers["crosshair"] = self getStat(1600);
	self.pers["draw_fps"] = self getStat(1601);
	self.pers["fullbright"] = self getStat(1602);
	self.pers["draw_distance"] = self getStat(1603);
	self.pers["xp_bar"] = self getStat(1605);
	self.pers["spec_hud"] = self getStat(1606);
	self.pers["velocity_metter"] = self getStat(1607);
	self.pers["compass"] = self getStat(1608);
	self.pers["hideplayers"] = self getStat(1609);
	self.pers["draw2D"] = self getStat(1610);
	self.pers["fxenabled"] = self getStat(1611);
	self.pers["knifeonly"] = self getStat(1612);
}

updateSettings()
{
	self endon("disconnect");

	if (!self.pers["crosshair"])
	{
		self setClientDvar( "sr_setting_value_0", "^1OFF");
		self setClientDvar( "cg_drawcrosshair", 0 );
	}
	else
	{
		self setClientDvar( "sr_setting_value_0", "^2ON");
		self setClientDvar( "cg_drawcrosshair", 1 );
	}

	if (!self.pers["draw_fps"])
	{
		self setClientDvar( "sr_setting_value_1", "^1OFF");
		self setClientDvar( "cg_drawfps", 0 );
	}
	else
	{
		self setClientDvar( "sr_setting_value_1", "^2ON");
		self setClientDvar( "cg_drawfps", 1 );
	}

	if (!self.pers["fullbright"])
	{
		self setClientDvar( "sr_setting_value_2", "^1OFF");
		self setClientDvar( "r_fullbright", 0 );
	}
	else
	{
		self setClientDvar( "sr_setting_value_2", "^2ON");
		self setClientDvar( "r_fullbright", 1 );
	}

	if (!self.pers["xp_bar"])
	{
		self setClientDvar( "sr_setting_value_3", "^1OFF");
		self setClientDvar("sr_xp_bar", 0);
	}
	else
	{
		self setClientDvar( "sr_setting_value_3", "^2ON");
		self setClientDvar("sr_xp_bar", 1);
	}

	if (!self.pers["spec_hud"])
		self setClientDvar( "sr_setting_value_4", "^1OFF");
	else
		self setClientDvar( "sr_setting_value_4", "^2ON");

	switch (self.pers["draw_distance"])
	{
		case 0:
			value = 0;
			self setClientDvar("sr_setting_value_5", "^3MAX");
			self setClientDvar("r_zfar", value );
			break;
		case 1:
			value = 5000;
			self setClientDvar("sr_setting_value_5", "^2" + value + "");
			self setClientDvar("r_zfar", value );
			break;
		case 2:
			value = 2500;
			self setClientDvar("sr_setting_value_5", "^2" + value + "");
			self setClientDvar("r_zfar", value );
			break;
		case 3:
			value = 1250;
			self setClientDvar("sr_setting_value_5", "^2" + value + "");
			self setClientDvar("r_zfar", value );
			break;
	}

	if (isDefined(self.pers["fovscale"]) && isDefined(self.fovscale))
	{
		value = self.fovscale / 1000;
		self setClientDvar("sr_setting_value_6", "^2" + value + "");
		self setClientDvar("cg_fovscale", value);
	}
	else if (isDefined(self.pers["fovscale"]) && !isDefined(self.fovscale))
	{
		value = self.pers["fovscale"] / 1000;
		self setClientDvar("sr_setting_value_6", "^2" + value + "");
		self setClientDvar("cg_fovscale", value);
	}

	switch (self.pers["velocity_metter"])
	{
		case 0:
			self setClientDvar("sr_setting_value_7", "^1OFF");
			break;
		case 1:
			self setClientDvar("sr_setting_value_7", "^2Top-Left");
			break;
		case 2:
			self setClientDvar("sr_setting_value_7", "^2Top-Center");
			break;
		case 3:
			self setClientDvar("sr_setting_value_7", "^2Top-Right");
			break;
		case 4:
			self setClientDvar("sr_setting_value_7", "^2Bottom-Left");
			break;
		case 5:
			self setClientDvar("sr_setting_value_7", "^2Bottom-Center");
			break;
		case 6:
			self setClientDvar("sr_setting_value_7", "^2Bottom-Right");
			break;
	}

	switch (self.pers["compass"])
	{
		case 0:
			self setClientDvar("sr_setting_value_8", "^1OFF");
			break;
		case 1:
			self setClientDvar("sr_setting_value_8", "^2Top-Left");
			break;
		case 2:
			self setClientDvar("sr_setting_value_8", "^2Top-Center");
			break;
		case 3:
			self setClientDvar("sr_setting_value_8", "^2Top-Right");
			break;
		case 4:
			self setClientDvar("sr_setting_value_8", "^2Bottom-Left");
			break;
		case 5:
			self setClientDvar("sr_setting_value_8", "^2Bottom-Center");
			break;
		case 6:
			self setClientDvar("sr_setting_value_8", "^2Bottom-Right");
			break;
	}

	switch (self.pers["hideplayers"])
	{
		case 0:
			self setClientDvar("sr_setting_value_9", "^1OFF");
			break;
		case 1:
			self setClientDvar("sr_setting_value_9", "^3Near");
			break;
		case 2:
			self setClientDvar("sr_setting_value_9", "^2All");
			break;
	}

	if (!self.pers["draw2D"])
	{
		self setClientDvar( "sr_setting_value_10", "^1OFF");
		self setClientDvar("cg_draw2D", 0);
	}
	else
	{
		self setClientDvar( "sr_setting_value_10", "^2ON");
		self setClientDvar("cg_draw2D", 1);
	}

	if (!self.pers["fxenabled"])
	{
		self setClientDvar( "sr_setting_value_11", "^1OFF");
		self setClientDvar("fx_enable", 0);
	}
	else
	{
		self setClientDvar( "sr_setting_value_11", "^2ON");
		self setClientDvar("fx_enable", 1);
	}

	if (!self.pers["knifeonly"])
		self setClientDvar( "sr_setting_value_12", "^1OFF");
	else
		self setClientDvar( "sr_setting_value_12", "^2ON");

	self thread saveOptions();
}

menuRes()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("menuresponse", menu, response);
		if( menu == "sr_settings" )
		{
			switch(response)
			{
				case "setting:0": self.pers["crosshair"] = !self.pers["crosshair"]; break;
				case "setting:1": self.pers["draw_fps"] = !self.pers["draw_fps"]; break;
				case "setting:2": self.pers["fullbright"] = !self.pers["fullbright"]; break;
				case "setting:3": self.pers["xp_bar"] = !self.pers["xp_bar"]; break;
				case "setting:4": self.pers["spec_hud"] = !self.pers["spec_hud"]; break;

				case "setting:5":
					if (self.pers["draw_distance"] == 3)
						self.pers["draw_distance"] = 0;
					else
						self.pers["draw_distance"]++;
					break;

				case "setting:6":
					self closeMenu();
					self closeInGameMenu();
					self iprintlnbold("Use ^2!fov ^7<1.0-2.0>");
					break;

				case "setting:7":
					if (self.pers["velocity_metter"] == 6)
						self.pers["velocity_metter"] = 0;
					else
						self.pers["velocity_metter"]++;
					break;

				case "setting:8":
					if (self.pers["compass"] == 6)
						self.pers["compass"] = 0;
					else
						self.pers["compass"]++;
					break;

				case "setting:9":
					if (self.pers["hideplayers"] == 2)
						self.pers["hideplayers"] = 0;
					else
						self.pers["hideplayers"]++;
					break;

				case "setting:10": self.pers["draw2D"] = !self.pers["draw2D"]; break;
				case "setting:11": self.pers["fxenabled"] = !self.pers["fxenabled"]; break;
				case "setting:12": self.pers["knifeonly"] = !self.pers["knifeonly"]; break;
			}
			self thread updateSettings();
		}
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

//FPS HUD
show_fps_hud()
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

check_lowfps()
{
	self endon("disconnect");

	if(isDefined(self.admin_group) && self.admin_group == "owner")
		return;

	self.check_lowfps = true;
	wait 0.05;

	if(self.real_fps < 1)
	{
		if(self.pers["team"] == "allies")
			self suicide();
	}

	self.check_lowfps = false;
}

check_ele()
{
	if(self.sr_cheatmode)
		return;

	self endon("disconnect");

	self.check_ele = true;
	before = self.origin;
	wait 0.05;

	if (!isDefined(self.real_velocity))
		return;

	if(self.origin[2] != before[2] && self.real_velocity == (0,0,0) && !self isOnGround() && !self isOnLadder() && !self isMantling())
	{
		if(self.pers["team"] == "allies" && !isDefined(self.disableAntiEle))
			self suicide();
	}
	self.check_ele = false;
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

	if (self.pers["velocity_metter"] != 0)
	{
		self.velocity_hud = addhud(self, 0, 0, 1, getHorizontal(self.pers["velocity_metter"]), getVertical(self.pers["velocity_metter"]), 1.6 );
		self.velocity_hud.archived = false;
		self.velocity_hud.horzAlign = getHorizontal(self.pers["velocity_metter"]);
		self.velocity_hud.vertAlign = getVertical(self.pers["velocity_metter"]);
		self.velocity_hud.hidewheninmenu = true;
	}
}

hidePlayers()
{
    while (true)
    {
        players = braxi\_common::getAllPlayers();
        for (i = 0; i < players.size; i++)
        {
            if (!isDefined(players[i].pers["team"]))
                continue;

            // Activator should be visible to everyone
            if (players[i].pers["team"] == "axis")
                players[i] show();
            else
                players[i] hide();
        }
        for (i = 0; i < players.size; i++)
        {
            for (j = 0; j < players.size; j++)
            {
                if ((!isDefined(players[j].ghost) || !players[j].ghost)
                    && (isDefined(players[i].pers) && isDefined(players[i].pers["hideplayers"]) || players[i].pers["team"] == "axis"))
                {
                    if (!players[i].pers["hideplayers"])
                        players[j] showToPlayer(players[i]);
                    // TODO HIDE NEAR PLAYERS
                    // else if (players[i].pers["hideplayers"] == 2 && distance2D(players[i].origin, players[j].origin) <= 3)
                    //     players[j] showToPlayer(players[i]);
                }
            }
        }
        wait 0.3;
    }
}

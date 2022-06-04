#include sr\sys\_events;

initSettings()
{
	menu_multiple("sr_settings", "setting", ::menu_setting);
}

onConnect()
{
	if (self.new) self reset();
	self load();

	self setClientDvar("cg_drawSpectatorMessages", "1");
	self setClientDvar("sr_setting_0", "Crosshair");
	self setClientDvar("sr_setting_1", "Draw FPS");
	self setClientDvar("sr_setting_2", "Fullbright");
	self setClientDvar("sr_setting_3", "XP Bar");
	self setClientDvar("sr_setting_4", "Spectator HUD");
	self setClientDvar("sr_setting_5", "Draw Distance");
	self setClientDvar("sr_setting_6", "FOV Scale");
	self setClientDvar("sr_setting_7", "Velocity Metter");
	self setClientDvar("sr_setting_8", "Compass");
	self setClientDvar("sr_setting_9", "Hide Players");
	self setClientDvar("sr_setting_10", "Draw 2D");
	self setClientDvar("sr_setting_11", "FX");
	self setClientDvar("sr_setting_12", "Knife Only");

	self update();
}

save()
{
	self endon("disconnect");

	self setStat(1600, self.settings["hud_crosshair"]);
	self setStat(1601, self.settings["hud_fps"]);
	self setStat(1605, self.settings["hud_xp"]);
	self setStat(1606, self.settings["hud_spectator"]);
	self setStat(1607, self.settings["hud_velocity"]);
	self setStat(1608, self.settings["hud_compass"]);
	self setStat(1610, self.settings["hud_2D"]);
	self setStat(1609, self.settings["player_hide"]);
	self setStat(1612, self.settings["player_knife"]);
	self setStat(2630, self.settings["gfx_fov"]);
	self setStat(1602, self.settings["gfx_fullbright"]);
	self setStat(1603, self.settings["gfx_distance"]);
	self setStat(1611, self.settings["gfx_fx"]);
}

load()
{
	self.settings["hud_crosshair"] 	= self getStat(1600);
	self.settings["hud_fps"] 		= self getStat(1601);
	self.settings["hud_xp"] 		= self getStat(1605);
	self.settings["hud_spectator"] 	= self getStat(1606);
	self.settings["hud_velocity"] 	= self getStat(1607);
	self.settings["hud_compass"] 	= self getStat(1608);
	self.settings["hud_2D"] 		= self getStat(1610);
	self.settings["player_hide"] 	= self getStat(1609);
	self.settings["player_knife"] 	= self getStat(1612);
	self.settings["gfx_fov"] 		= self getStat(2630);
	self.settings["gfx_fullbright"] = self getStat(1602);
	self.settings["gfx_distance"] 	= self getStat(1603);
	self.settings["gfx_fx"] 		= self getStat(1611);
}

reset()
{
	self.settings["hud_crosshair"] 	= true;
	self.settings["hud_fps"] 		= true;
	self.settings["hud_xp"] 		= false;
	self.settings["hud_spectator"] 	= true;
	self.settings["hud_velocity"] 	= 4;
	self.settings["hud_compass"] 	= false;
	self.settings["hud_2D"] 		= true;
	self.settings["player_hide"] 	= false;
	self.settings["player_knife"] 	= false;
	self.settings["gfx_distance"] 	= false;
	self.settings["gfx_fov"] 		= 1000;
	self.settings["gfx_fullbright"] = false;
	self.settings["gfx_fx"] 		= true;
	self save();
}

update_hudCrosshair()
{
	value = self.settings["hud_crosshair"];
	self setClientDvar("cg_drawcrosshair", value);
	updateHud(0, value);
}

update_hudFPS()
{
	value = self.settings["hud_fps"];
	self setClientDvar("cg_drawfps", value);
	updateHud(1, value);
}

update_hudXP()
{
	value = self.settings["hud_xp"];
	self setClientDvar("sr_xp_bar", value);
	updateHud(3, value);
}

update_hudSpectator()
{
	value = self.settings["hud_spectator"];
	updateHud(4, value);
}

update_hudVelocity()
{
	value = self.settings["hud_velocity"];
	labels = strTok("^1OFF,^2Top-Left,^2Top-Center,^2Top-Right,^2Bottom-Left,^2Bottom-Center,^2Bottom-Right", ",");
	updateHud(7, value, labels[value]);
}

update_hudCompass()
{
	value = self.settings["hud_compass"];
	labels = strTok("^1OFF,^2Top-Left,^2Top-Center,^2Top-Right,^2Bottom-Left,^2Bottom-Center,^2Bottom-Right", ",");
	updateHud(8, value, labels[value]);
}

update_hud2D()
{
	value = self.settings["hud_2D"];
	self setClientDvar("cg_draw2D", value);
	updateHud(10, value);
}

update_playerHide()
{
	value = self.settings["player_hide"];
	labels = strTok("^1OFF,^3Near,^2All", ",");
	updateHud(9, value, labels[value]);
}

update_playerKnife()
{
	value = self.settings["player_knife"];
	updateHud(12, value);
}

update_gfxFOV()
{
	value = self.settings["gfx_fov"] / 1000;
	self setClientDvar("cg_fovscale", value);
	updateHud(6, value, fmt("^2%f", value));
}

update_gfxFullbright()
{
	value = self.settings["gfx_fullbright"];
	self setClientDvar("r_fullbright", value);
	updateHud(2, value);
}

update_gfxDistance()
{
	value = self.settings["gfx_distance"];
	distances = Cast(strTok("0,5000,2500,1250", ","), "int");
	labels = strTok("^3MAX,^25000,^22500,^21250", ",");

	distance = distances[value];
	self setClientDvar("r_zfar", distance);
	updateHud(5, value, labels[value]);
}

update_gfxFX()
{
	value = self.settings["gfx_fx"];
	self setClientDvar("fx_enable", value);
	updateHud(2, value);
}

update()
{
	self endon("disconnect");

	self update_hudCrosshair();
	self update_hudFPS();
	self update_hudXP();
	self update_hudSpectator();
	self update_hudVelocity();
	self update_hudCompass();
	self update_hud2D();
	self update_playerHide();
	self update_playerKnife();
	self update_gfxFOV();
	self update_gfxFullbright();
	self update_gfxDistance();

	self thread save();
}

updateHud(index, state, string)
{
	value = IfUndef(string, Ternary(state, "^2ON", "^1OFF"));
	self setClientDvar("sr_setting_value_" + index, value);
}

menu_setting(response)
{
	self endon("disconnect");

	switch (response)
	{
		case "setting:0": 	self.settings["hud_crosshair"] 	= !self.settings["hud_crosshair"]; 				break;
		case "setting:1": 	self.settings["hud_fps"] 		= !self.settings["hud_fps"]; 					break;
		case "setting:2": 	self.settings["gfx_fullbright"] = !self.settings["gfx_fullbright"]; 			break;
		case "setting:3": 	self.settings["hud_xp"] 		= !self.settings["hud_xp"]; 					break;
		case "setting:4": 	self.settings["hud_spectator"] 	= !self.settings["hud_spectator"]; 				break;
		case "setting:5": 	self.settings["gfx_distance"] 	= range(self.settings["gfx_distance"], 0, 3);	break;
		case "setting:6": 	self menu_FOV();																break;
		case "setting:7": 	self.settings["gfx_distance"] 	= range(self.settings["hud_velocity"], 0, 6);	break;
		case "setting:8": 	self.settings["hud_compass"] 	= range(self.settings["hud_velocity"], 0, 6);	break;
		case "setting:9": 	self.settings["player_hide"] 	= range(self.settings["hud_velocity"], 0, 2);	break;
		case "setting:10": 	self.settings["hud_2D"] 		= !self.settings["hud_2D"]; 					break;
		case "setting:11": 	self.settings["gfx_fx"] 		= !self.settings["gfx_fx"]; 					break;
		case "setting:12": 	self.settings["player_knife"] 	= !self.settings["player_knife"]; 				break;
	}
	self thread update();
}

menu_FOV()
{
	self closeMenu();
	self closeInGameMenu();
	self iprintlnbold("Use ^2!fov ^7<1.0-2.0>");
}

check_lowfps()
{
	self endon("disconnect");

	if (isDefined(self.admin_group) && self.admin_group == "owner")
		return;

	self.check_lowfps = true;
	wait 0.05;

	if (self.fps < 1)
	{
		if (self.pers["team"] == "allies")
			self suicide();
	}
	self.check_lowfps = false;
}

check_ele()
{
	if (self.sr_cheatmode)
		return;

	self endon("disconnect");

	self.check_ele = true;
	before = self.origin;
	wait 0.05;

	if (!isDefined(self.real_velocity))
		return;

	if (self.origin[2] != before[2] && self.real_velocity == (0,0,0) && !self isOnGround() && !self isOnLadder() && !self isMantling())
	{
		if (self.pers["team"] == "allies" && !isDefined(self.disableAntiEle))
			self suicide();
	}
	self.check_ele = false;
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
                    && (isDefined(players[i].settings) && isDefined(players[i].settings["player_hide"]) || players[i].pers["team"] == "axis"))
                {
                    if (!players[i].settings["player_hide"])
                        players[j] showToPlayer(players[i]);
                    // TODO HIDE NEAR PLAYERS
                    // else if (players[i].settings["player_hide"] == 2 && distance2D(players[i].origin, players[j].origin) <= 3)
                    //     players[j] showToPlayer(players[i]);
                }
            }
        }
        wait 0.3;
    }
}

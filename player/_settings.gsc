#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

main()
{
	menu_multiple("sr_settings", "setting", ::menu_setting);

	event("connect", ::onConnect);
}

onConnect()
{
	if (isDefined(self.new)) self reset();
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
	self.settings["hud_velocity"] 	= 5;
	self.settings["hud_compass"] 	= 5;
	self.settings["hud_2D"] 		= true;
	self.settings["player_hide"] 	= false;
	self.settings["player_knife"] 	= false;
	self.settings["gfx_distance"] 	= 0;
	self.settings["gfx_fov"] 		= 1000;
	self.settings["gfx_fullbright"] = false;
	self.settings["gfx_fx"] 		= true;
	self save();
}

update_hudCrosshair(num)
{
	value = self.settings["hud_crosshair"];
	self setClientDvar("cg_drawcrosshair", value);
	self updateHud(num, value);
}

update_hudFPS(num)
{
	value = self.settings["hud_fps"];
	self setClientDvar("cg_drawfps", value);
	self updateHud(num, value);
}

update_hudXP(num)
{
	value = self.settings["hud_xp"];
	self setClientDvar("sr_xp_bar", value);
	self updateHud(num, value);
}

update_hudSpectator(num)
{
	value = self.settings["hud_spectator"];
	self updateHud(num, value);
}

update_hudVelocity(num)
{
	value = self.settings["hud_velocity"];
	labels = strTok("^1OFF;^2Top-Left;^2Top-Center;^2Top-Right;^2Bottom-Left;^2Bottom-Center;^2Bottom-Right;", ";");
	self updateHud(num, value, labels[value]);

	if (isDefined(self.huds["velocity"]))
	{
		self.huds["velocity"].alignX = getHorizontal(self.settings["hud_velocity"]);
		self.huds["velocity"].horzAlign = getHorizontal(self.settings["hud_velocity"]);
		self.huds["velocity"].alignY = getVertical(self.settings["hud_velocity"]);
		self.huds["velocity"].vertAlign = getVertical(self.settings["hud_velocity"]);
	}
}

update_hudCompass(num)
{
	value = self.settings["hud_compass"];
	labels = strTok("^1OFF;^2Top-Left;^2Top-Center;^2Top-Right;^2Bottom-Left;^2Bottom-Center;^2Bottom-Right;", ";");
	self updateHud(num, value, labels[value]);
}

update_hud2D(num)
{
	value = self.settings["hud_2D"];
	self setClientDvar("cg_draw2D", value);
	self updateHud(num, value);
}

update_playerHide(num)
{
	value = self.settings["player_hide"];
	labels = strTok("^1OFF;^3Near;^2All;", ";");
	self updateHud(num, value, labels[value]);
}

update_playerKnife(num)
{
	value = self.settings["player_knife"];
	self updateHud(num, value);
}

update_gfxFOV(num)
{
	value = float(self.settings["gfx_fov"] / 1000);
	self setClientDvar("cg_fovscale", value);
	self updateHud(num, value > 0, fmt("^5%.3f", value));
}

update_gfxFullbright(num)
{
	value = self.settings["gfx_fullbright"];
	self setClientDvar("r_fullbright", value);
	self updateHud(num, value);
}

update_gfxDistance(num)
{
	value = self.settings["gfx_distance"];
	distances = Cast(strTok("0;5000;2500;1250;500;", ";"), "int");
	labels = strTok("^3MAX;^25000;^22500;^21250;^2500;", ";");

	distance = distances[value];
	self setClientDvar("r_zfar", distance);
	self updateHud(num, value, labels[value]);
}

update_gfxFX(num)
{
	value = self.settings["gfx_fx"];
	self setClientDvar("fx_enable", value);
	self updateHud(num, value);
}

update()
{
	self endon("disconnect");

	self update_hudCrosshair(0);
	self update_hudFPS(1);
	self update_hudXP(3);
	self update_hudSpectator(4);
	self update_hudVelocity(7);
	self update_hudCompass(8);
	self update_hud2D(10);
	self update_playerHide(9);
	self update_playerKnife(12);
	self update_gfxFOV(6);
	self update_gfxFullbright(2);
	self update_gfxDistance(5);
	self update_gfxFX(11);

	self thread save();
}

updateHud(index, state, string)
{
	value = IfUndef(string, Ternary(state, "^2ON", "^1OFF"));
	self setClientDvar("sr_setting_value_" + index, value);
}

menu_setting(args)
{
	self endon("disconnect");

	switch (ToInt(args[1]))
	{
		case 0: 	self.settings["hud_crosshair"] 	= !self.settings["hud_crosshair"]; 					break;
		case 1: 	self.settings["hud_fps"] 		= !self.settings["hud_fps"]; 						break;
		case 2: 	self.settings["gfx_fullbright"] = !self.settings["gfx_fullbright"]; 				break;
		case 3: 	self.settings["hud_xp"] 		= !self.settings["hud_xp"]; 						break;
		case 4: 	self.settings["hud_spectator"] 	= !self.settings["hud_spectator"]; 					break;
		case 5: 	self.settings["gfx_distance"] 	= intRange(self.settings["gfx_distance"], 0, 4);	break;
		case 6: 	self menu_FOV();																	break;
		case 7: 	self.settings["hud_velocity"] 	= intRange(self.settings["hud_velocity"], 0, 6);	break;
		case 8: 	self.settings["hud_compass"] 	= intRange(self.settings["hud_compass"], 0, 6);		break;
		case 9: 	self.settings["player_hide"] 	= intRange(self.settings["player_hide"], 0, 2);		break;
		case 10: 	self.settings["hud_2D"] 		= !self.settings["hud_2D"]; 						break;
		case 11: 	self.settings["gfx_fx"] 		= !self.settings["gfx_fx"]; 						break;
		case 12: 	self.settings["player_knife"] 	= !self.settings["player_knife"]; 					break;
	}
	self update();
}

menu_FOV()
{
	self closeMenu();
	self closeInGameMenu();
	self sr\commands\_graphics::cmd_FOV([]);
}

hidePlayers()
{
    while (true)
    {
        players = getAllPlayers();
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

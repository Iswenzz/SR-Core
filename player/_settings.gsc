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
	self endon("disconnect");

	if (isDefined(self.new)) self reset();
	self load();

	wait 1;

	wait 0.05;
	self setClientDvar("cg_drawSpectatorMessages", "1");
	self setClientDvar("sr_setting_0", "Crosshair");
	self setClientDvar("sr_setting_1", "Draw FPS");
	self setClientDvar("sr_setting_2", "Fullbright");
	self setClientDvar("sr_setting_3", "XP Bar");
	self setClientDvar("sr_setting_4", "Keys");
	wait 0.05;
	self setClientDvar("sr_setting_5", "Draw Distance");
	self setClientDvar("sr_setting_6", "FOV Scale");
	self setClientDvar("sr_setting_7", "Velocity Metter");
	self setClientDvar("sr_setting_8", "Compass");
	self setClientDvar("sr_setting_9", "Hide Players");
	self setClientDvar("sr_setting_10", "Draw 2D");
	wait 0.05;
	self setClientDvar("sr_setting_11", "FX");
	self setClientDvar("sr_setting_12", "Knife Only");
	self setClientDvar("sr_setting_13", "Velocity Info");
	self setClientDvar("sr_setting_14", "FPS Combo");
	self setClientDvar("sr_setting_15", "Ground Time");
	self setClientDvar("sr_setting_16", "CGAZ HUD");
	wait 0.05;
	self setClientDvar("sr_setting_17", "Snap HUD");
	self setClientDvar("sr_setting_18", "Ragdoll");
	self setClientDvar("sr_setting_19", "Music Animations");

	self update();
}

save()
{
	self endon("disconnect");

	self setStat(1600, self.settings["hud_crosshair"]);
	self setStat(1601, self.settings["hud_fps"]);
	self setStat(1614, self.settings["hud_fps_combo"]);
	self setStat(1605, self.settings["hud_xp"]);
	self setStat(1615, self.settings["hud_keys"]);
	self setStat(1607, self.settings["hud_velocity"]);
	self setStat(1613, self.settings["hud_velocity_info"]);
	self setStat(1614, self.settings["hud_velocity_ground"]);
	self setStat(1608, self.settings["hud_compass"]);
	self setStat(1616, self.settings["hud_cgaz"]);
	self setStat(1617, self.settings["hud_snap"]);
	self setStat(1610, self.settings["hud_2D"]);
	self setStat(1609, self.settings["player_hide"]);
	self setStat(1612, self.settings["player_knife"]);
	self setStat(2630, self.settings["gfx_fov"]);
	self setStat(1602, self.settings["gfx_fullbright"]);
	self setStat(1603, self.settings["gfx_distance"]);
	self setStat(1611, self.settings["gfx_fx"]);
	self setStat(1618, self.settings["gfx_ragdoll"]);
	self setStat(1619, !self.settings["gfx_music_animation"]);
}

load()
{
	self.settings["hud_crosshair"] 			= self getStat(1600);
	self.settings["hud_fps"] 				= self getStat(1601);
	self.settings["hud_fps_combo"] 			= self getStat(1614);
	self.settings["hud_xp"] 				= self getStat(1605);
	self.settings["hud_keys"] 				= self getStat(1615);
	self.settings["hud_velocity"] 			= self getStat(1607);
	self.settings["hud_velocity_info"] 		= self getStat(1613);
	self.settings["hud_velocity_ground"] 	= self getStat(1614);
	self.settings["hud_compass"] 			= self getStat(1608);
	self.settings["hud_cgaz"] 				= self getStat(1616);
	self.settings["hud_snap"] 				= self getStat(1617);
	self.settings["hud_2D"] 				= self getStat(1610);
	self.settings["player_hide"] 			= self getStat(1609);
	self.settings["player_knife"] 			= self getStat(1612);
	self.settings["gfx_fov"] 				= self getStat(2630);
	self.settings["gfx_fullbright"] 		= self getStat(1602);
	self.settings["gfx_distance"] 			= self getStat(1603);
	self.settings["gfx_fx"] 				= self getStat(1611);
	self.settings["gfx_ragdoll"] 			= self getStat(1618);
	self.settings["gfx_music_animation"] 	= !self getStat(1619);
}

reset()
{
	self.settings["hud_crosshair"] 			= 2;
	self.settings["hud_fps"] 				= true;
	self.settings["hud_fps_combo"] 			= false;
	self.settings["hud_xp"] 				= false;
	self.settings["hud_keys"] 				= false;
	self.settings["hud_velocity"] 			= 8;
	self.settings["hud_velocity_info"] 		= 0;
	self.settings["hud_velocity_ground"]	= 0;
	self.settings["hud_compass"] 			= 8;
	self.settings["hud_cgaz"] 				= false;
	self.settings["hud_snap"] 				= false;
	self.settings["hud_2D"] 				= true;
	self.settings["player_hide"] 			= false;
	self.settings["player_knife"] 			= false;
	self.settings["gfx_distance"] 			= 0;
	self.settings["gfx_fov"] 				= 1000;
	self.settings["gfx_fullbright"] 		= false;
	self.settings["gfx_fx"] 				= true;
	self.settings["gfx_ragdoll"] 			= false;
	self.settings["gfx_music_animation"] 	= true;
	self save();
}

update_hudCrosshair(num)
{
	value = self.settings["hud_crosshair"];
	labels = strTok("^1OFF;^2Stock;^5Quake;", ";");
	self setClientDvar("cg_drawCrosshair", value == 1);
	self updateHud(num, value, labels[value]);
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

update_hudKeys(num)
{
	value = self.settings["hud_keys"];
	self updateHud(num, value);
}

update_hudVelocity(num)
{
	value = self.settings["hud_velocity"];
	labels = strTok("^1OFF;^2Top-Left;^2Top-Center;^2Top-Right;^2Middle-Left;^2Middle-Center;^2Middle-Right;^2Bottom-Left;^2Bottom-Center;^2Bottom-Right;", ";");
	self updateHud(num, value, labels[value]);
}

update_hudCompass(num)
{
	value = self.settings["hud_compass"];
	labels = strTok("^1OFF;^2Top-Left;^2Top-Center;^2Top-Right;^2Middle-Left;^2Middle-Center;^2Middle-Right;^2Bottom-Left;^2Bottom-Center;^2Bottom-Right;", ";");
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
	labels = strTok("^1OFF;^3Near;^6All;", ";");
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
	distances = strTok("0;5000;2500;1250;500;", ";");
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

update_gfxRagdoll(num)
{
	value = self.settings["gfx_ragdoll"];
	self setClientDvar("ragdoll_enable", value);
	self updateHud(num, value);
}

update_gfxMusicAnimation(num)
{
	value = self.settings["gfx_music_animation"];
	self updateHud(num, value);
}

update_hudVelocityInfo(num)
{
	value = self.settings["hud_velocity_info"];
	labels = strTok("^5Default;^3Average;^6Max;", ";");
	self updateHud(num, value, labels[value]);
}

update_hudFPSCombo(num)
{
	value = self.settings["hud_fps_combo"];
	self updateHud(num, value);
}

update_hudVelocityGround(num)
{
	value = self.settings["hud_velocity_ground"];
	labels = strTok("^1OFF;^5Time;^3Average;", ";");
	self updateHud(num, value, labels[value]);
}

update_hudCgaz(num)
{
	value = self.settings["hud_cgaz"];
	self updateHud(num, value);

	if (value && !self getStat(2400) && !self getStat(2401))
		self sr\sys\_admins::pm("^3CGAZ: Please set your screen resolution using ^7!hud_res <1920x1080>");
	if (value && !self getStat(2402))
		self sr\sys\_admins::pm("^3CGAZ: Please set your fov using ^7!hud_fov <65-80>");
}

update_hudSnap(num)
{
	value = self.settings["hud_snap"];
	labels = strTok("^1OFF;^5Normal;^645;^9Height;", ";");
	self updateHud(num, value, labels[value]);

	if (value && !self getStat(2400) && !self getStat(2401))
		self sr\sys\_admins::pm("^3CGAZ: Please set your screen resolution using ^7!hud_res <1920x1080>");
	if (value && !self getStat(2402))
		self sr\sys\_admins::pm("^3CGAZ: Please set your fov using ^7!hud_fov <65-80>");
}

update()
{
	self endon("disconnect");

	wait 0.05;
	self update_hudCrosshair(0);
	self update_hudFPS(1);
	self update_hudFPSCombo(14);
	self update_hudXP(3);
	self update_hudKeys(4);
	self update_hudVelocity(7);
	wait 0.05;
	self update_hudVelocityInfo(13);
	self update_hudVelocityGround(15);
	self update_hudCompass(8);
	self update_hudCgaz(16);
	self update_hudSnap(17);
	self update_hud2D(10);
	wait 0.05;
	self update_playerHide(9);
	self update_playerKnife(12);
	self update_gfxFOV(6);
	self update_gfxFullbright(2);
	self update_gfxDistance(5);
	self update_gfxFX(11);
	wait 0.05;
	self update_gfxRagdoll(18);
	self update_gfxMusicAnimation(19);

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
		case 0: 	self.settings["hud_crosshair"] 			= intRange(self.settings["hud_crosshair"], 0, 2); 			break;
		case 1: 	self.settings["hud_fps"] 				= !self.settings["hud_fps"]; 								break;
		case 2: 	self.settings["gfx_fullbright"] 		= !self.settings["gfx_fullbright"]; 						break;
		case 3: 	self.settings["hud_xp"] 				= !self.settings["hud_xp"]; 								break;
		case 4: 	self.settings["hud_keys"] 				= !self.settings["hud_keys"]; 								break;
		case 5: 	self.settings["gfx_distance"] 			= intRange(self.settings["gfx_distance"], 0, 4);			break;
		case 6: 	self menu_FOV();																					break;
		case 7: 	self.settings["hud_velocity"] 			= intRange(self.settings["hud_velocity"], 0, 9);			break;
		case 8: 	self.settings["hud_compass"] 			= intRange(self.settings["hud_compass"], 0, 9);				break;
		case 9: 	self.settings["player_hide"] 			= intRange(self.settings["player_hide"], 0, 2);				break;
		case 10: 	self.settings["hud_2D"] 				= !self.settings["hud_2D"]; 								break;
		case 11: 	self.settings["gfx_fx"] 				= !self.settings["gfx_fx"]; 								break;
		case 12: 	self.settings["player_knife"] 			= !self.settings["player_knife"]; 							break;
		case 13: 	self.settings["hud_velocity_info"] 		= intRange(self.settings["hud_velocity_info"], 0, 2); 		break;
		case 14: 	self.settings["hud_fps_combo"] 			= !self.settings["hud_fps_combo"]; 							break;
		case 15: 	self.settings["hud_velocity_ground"] 	= intRange(self.settings["hud_velocity_ground"], 0, 2); 	break;
		case 16: 	self.settings["hud_cgaz"] 				= !self.settings["hud_cgaz"]; 								break;
		case 17: 	self.settings["hud_snap"] 				= intRange(self.settings["hud_snap"], 0, 3);				break;
		case 18: 	self.settings["gfx_ragdoll"] 			= !self.settings["gfx_ragdoll"];							break;
		case 19: 	self.settings["gfx_music_animation"] 	= !self.settings["gfx_music_animation"];						break;
	}
	self update();
}

menu_FOV()
{
	self closeMenu();
	self closeInGameMenu();
	self sr\commands\_graphics::cmd_FOV([]);
}

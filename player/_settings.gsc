#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

main()
{
	level.settings = [];

	settings(0,  "hud_crosshair", "Crosshair", 1600, 2, ::update_hudCrosshair, ::toggle_hudCrosshair);
	settings(1,  "hud_fps", "Draw FPS", 1601, true, ::update_hudFPS, ::toggle_hudFPS);
	settings(14, "hud_fps_combo", "FPS Combo", 1621, false, ::update_hudFPSCombo, ::toggle_hudFPSCombo);
	settings(3,  "hud_xp", "XP Bar", 1605, false, ::update_hudXP, ::toggle_hudXP);
	settings(4,  "hud_keys", "Keys", 1615, false, ::update_hudKeys, ::toggle_hudKeys);
	settings(7,  "hud_velocity", "Velocity Metter", 1607, 8, ::update_hudVelocity, ::toggle_hudVelocity);
	settings(13, "hud_velocity_info", "Velocity Info", 1613, 0, ::update_hudVelocityInfo, ::toggle_hudVelocityInfo);
	settings(15, "hud_velocity_ground", "Ground Time", 1614, 0, ::update_hudVelocityGround, ::toggle_hudVelocityGround);
	settings(8,  "hud_compass", "Compass", 1608, 8, ::update_hudCompass, ::toggle_hudCompass);
	settings(16, "hud_cgaz", "CGAZ HUD", 1616, false, ::update_hudCgaz, ::toggle_hudCgaz);
	settings(10, "hud_2D", "Draw 2D", 1610, true, ::update_hud2D, ::toggle_hud2D);
	settings(9,  "player_hide", "Hide Players", 1609, false, ::update_playerHide, ::toggle_playerHide);
	settings(12, "player_knife", "Knife Only", 1612, false, ::update_playerKnife, ::toggle_playerKnife);
	settings(19, "player_voice", "Voice chat", 1620, true, ::update_playerVoice, ::toggle_playerVoice);
	settings(20, "player_proximity", "Voice proximity", 1621, true, ::update_playerProximity, ::toggle_playerProximity);
	settings(21, "player_radio", "Radio", 1622, true, ::update_playerRadio, ::toggle_playerRadio);
	settings(6,  "gfx_fov", "FOV Scale", 2630, 1000, ::update_gfxFOV, ::toggle_gfxFOV);
	settings(2,  "gfx_fullbright", "Fullbright", 1602, false, ::update_gfxFullbright, ::toggle_gfxFullbright);
	settings(5,  "gfx_distance", "Draw Distance", 1603, 0, ::update_gfxDistance, ::toggle_gfxDistance);
	settings(11, "gfx_fx", "FX", 1611, true, ::update_gfxFX, ::toggle_gfxFX);
	settings(17, "gfx_ragdoll", "Ragdoll", 1618, false, ::update_gfxRagdoll, ::toggle_gfxRagdoll);
	settings(18, "gfx_music_animation", "Music Animations", 1619, true, ::update_gfxMusicAnimation, ::toggle_gfxMusicAnimation);

	menu_multiple("sr_settings", "setting", ::menu_Setting);
	event("connect", ::onConnect);
}

settings(index, id, name, stat, value, updateCallback, toggleCallback)
{
	level.settings[index] = spawnStruct();
	level.settings[index].name = name;
	level.settings[index].index = index;
	level.settings[index].id = id;
	level.settings[index].stat = stat;
	level.settings[index].value = value;
	level.settings[index].updateCallback = updateCallback;
	level.settings[index].toggleCallback = toggleCallback;
}

menu_Setting(args)
{
	self endon("disconnect");

	index = ToInt(args[1]);
	setting = level.settings[index];
	toggle(setting.id);
}

onConnect()
{
	self endon("disconnect");
	self.settings = [];

	if (isDefined(self.new))
		self reset();
	self load();
}

save()
{
	self endon("disconnect");

	for (i = 0; i < level.settings.size; i++)
		self setStat(level.settings[i].stat, self.settings[level.settings[i].id]);
}

load()
{
	for (i = 0; i < level.settings.size; i++)
	{
		setting = level.settings[i];
		self.settings[setting.id] = self getStat(setting.stat);
		self [[setting.updateCallback]](setting);
	}

	wait 1;
	for (i = 0; i < level.settings.size; i++)
	{
		if (!(i % 5))
			wait 0.05;
		self setClientDvar(fmt("sr_setting_%d", i), level.settings[i].name);
	}
}

reset()
{
	for (i = 0; i < level.settings.size; i++)
		self.settings[level.settings[i].id] = level.settings[i].value;

	self save();
}

update(id)
{
	setting = getSetting(id);
	if (!isDefined(setting))
		return;

	self [[setting.updateCallback]](setting);
	self save();
}

toggle(id)
{
	setting = getSetting(id);
	if (!isDefined(setting))
		return;

	self [[setting.toggleCallback]](setting);
	self [[setting.updateCallback]](setting);

	self save();
}

getSetting(id)
{
	setting = undefined;
	for (i = 0; i < level.settings.size; i++)
	{
		if (level.settings[i].id == id)
		{
			setting = level.settings[i];
			break;
		}
	}
	return setting;
}

updateHud(index, state, string)
{
	value = IfUndef(string, Ternary(state, "^2ON", "^1OFF"));
	self setClientDvar("sr_setting_value_" + index, value);
}

update_hudCrosshair(setting)
{
	value = self.settings["hud_crosshair"];
	labels = strTok("^1OFF;^2Stock;^5Quake;", ";");
	self setClientDvar("cg_drawCrosshair", value == 1);
	self updateHud(setting.index, value, labels[value]);
}

update_hudFPS(setting)
{
	value = self.settings["hud_fps"];
	self setClientDvar("cg_drawfps", value);
	self updateHud(setting.index, value);
}

update_hudXP(setting)
{
	value = self.settings["hud_xp"];
	self setClientDvar("sr_xp_bar", value);
	self updateHud(setting.index, value);
}

update_hudKeys(setting)
{
	value = self.settings["hud_keys"];
	self updateHud(setting.index, value);
}

update_hudVelocity(setting)
{
	value = self.settings["hud_velocity"];
	labels = strTok("^1OFF;^2Top-Left;^2Top-Center;^2Top-Right;^2Middle-Left;^2Middle-Center;^2Middle-Right;^2Bottom-Left;^2Bottom-Center;^2Bottom-Right;", ";");
	self updateHud(setting.index, value, labels[value]);
}

update_hudCompass(setting)
{
	value = self.settings["hud_compass"];
	labels = strTok("^1OFF;^2Top-Left;^2Top-Center;^2Top-Right;^2Middle-Left;^2Middle-Center;^2Middle-Right;^2Bottom-Left;^2Bottom-Center;^2Bottom-Right;", ";");
	self updateHud(setting.index, value, labels[value]);
}

update_hud2D(setting)
{
	value = self.settings["hud_2D"];
	self setClientDvar("cg_draw2D", value);
	self updateHud(setting.index, value);
}

update_playerHide(setting)
{
	value = self.settings["player_hide"];
	labels = strTok("^1OFF;^3Near;^6All;", ";");
	self updateHud(setting.index, value, labels[value]);
}

update_playerKnife(setting)
{
	value = self.settings["player_knife"];
	self updateHud(setting.index, value);
}

update_playerVoice(setting)
{
	value = self.settings["player_voice"];
	self setClientDvar("cl_voice", value);
	self updateHud(setting.index, value);
}

update_playerProximity(setting)
{
	value = self.settings["player_proximity"];
	self ProximityEnable(value);
	self updateHud(setting.index, value);
}

update_playerRadio(setting)
{
	value = self.settings["player_radio"];
	self RadioEnable(value);
	self updateHud(setting.index, value);
}

update_gfxFOV(setting)
{
	value = float(self.settings["gfx_fov"] / 1000);
	self setClientDvar("cg_fovscale", value);
	self updateHud(setting.index, value > 0, fmt("^5%.3f", value));
}

update_gfxFullbright(setting)
{
	value = self.settings["gfx_fullbright"];
	self setClientDvar("r_fullbright", value);
	self updateHud(setting.index, value);
}

update_gfxDistance(setting)
{
	value = self.settings["gfx_distance"];
	distances = strTok("0;5000;2500;1250;500;", ";");
	labels = strTok("^3MAX;^25000;^22500;^21250;^2500;", ";");

	distance = distances[value];
	self setClientDvar("r_zfar", distance);
	self updateHud(setting.index, value, labels[value]);
}

update_gfxFX(setting)
{
	value = self.settings["gfx_fx"];
	self setClientDvar("fx_enable", value);
	self updateHud(setting.index, value);
}

update_gfxRagdoll(setting)
{
	value = self.settings["gfx_ragdoll"];
	self setClientDvar("ragdoll_enable", value);
	self updateHud(setting.index, value);
}

update_gfxMusicAnimation(setting)
{
	value = self.settings["gfx_music_animation"];
	self updateHud(setting.index, value);
}

update_hudVelocityInfo(setting)
{
	value = self.settings["hud_velocity_info"];
	labels = strTok("^5Default;^3Average;^6Max;", ";");
	self updateHud(setting.index, value, labels[value]);
}

update_hudFPSCombo(setting)
{
	value = self.settings["hud_fps_combo"];
	self updateHud(setting.index, value);
}

update_hudVelocityGround(setting)
{
	value = self.settings["hud_velocity_ground"];
	labels = strTok("^1OFF;^5Time;^3Average;", ";");
	self updateHud(setting.index, value, labels[value]);
}

update_hudCgaz(setting)
{
	value = self.settings["hud_cgaz"];
	self updateHud(setting.index, value);

	if (value && !self getStat(2400) && !self getStat(2401))
		self sr\sys\_admins::pm("^3CGAZ: Please set your screen resolution using ^7!hud_res <1920x1080>");
	if (value && !self getStat(2402))
		self sr\sys\_admins::pm("^3CGAZ: Please set your fov using ^7!hud_fov <65-80>");
}

toggle_hudCrosshair(setting)
{
	self.settings["hud_crosshair"] = intRange(self.settings["hud_crosshair"], 0, 2);
}

toggle_hudFPS(setting)
{
	self.settings["hud_fps"] = !self.settings["hud_fps"];
}

toggle_hudFPSCombo(setting)
{
	self.settings["hud_fps_combo"] = !self.settings["hud_fps_combo"];
}

toggle_hudXP(setting)
{
	self.settings["hud_xp"] = !self.settings["hud_xp"];
}

toggle_hudKeys(setting)
{
	self.settings["hud_keys"] = !self.settings["hud_keys"];
}

toggle_hudVelocity(setting)
{
	self.settings["hud_velocity"] = intRange(self.settings["hud_velocity"], 0, 9);
}

toggle_hudVelocityInfo(setting)
{
	self.settings["hud_velocity_info"] = intRange(self.settings["hud_velocity_info"], 0, 2);
}

toggle_hudVelocityGround(setting)
{
	self.settings["hud_velocity_ground"] = intRange(self.settings["hud_velocity_ground"], 0, 2);
}

toggle_hudCompass(setting)
{
	self.settings["hud_compass"] = intRange(self.settings["hud_compass"], 0, 9);
}

toggle_hudCgaz(setting)
{
	self.settings["hud_cgaz"] = !self.settings["hud_cgaz"];
}

toggle_hud2D(setting)
{
	self.settings["hud_2D"] = !self.settings["hud_2D"];
}

toggle_playerHide(setting)
{
	self.settings["player_hide"] = intRange(self.settings["player_hide"], 0, 2);
}

toggle_playerKnife(setting)
{
	self.settings["player_knife"] = !self.settings["player_knife"];
}

toggle_playerVoice(setting)
{
	self.settings["player_voice"] = !self.settings["player_voice"];
}

toggle_playerProximity(setting)
{
	self.settings["player_proximity"] = !self.settings["player_proximity"];
}

toggle_playerRadio(setting)
{
	self.settings["player_radio"] = !self.settings["player_radio"];
}

toggle_gfxDistance(setting)
{
	self.settings["gfx_distance"] = intRange(self.settings["gfx_distance"], 0, 4);
}

toggle_gfxFOV(setting)
{
	self closeMenu();
	self closeInGameMenu();

	self sr\sys\_admins::command("fov");
}

toggle_gfxFullbright(setting)
{
	self.settings["gfx_fullbright"] = !self.settings["gfx_fullbright"];
}

toggle_gfxFX(setting)
{
	self.settings["gfx_fx"] = !self.settings["gfx_fx"];
}

toggle_gfxRagdoll(setting)
{
	self.settings["gfx_ragdoll"] = !self.settings["gfx_ragdoll"];
}

toggle_gfxMusicAnimation(setting)
{
	self.settings["gfx_music_animation"] = !self.settings["gfx_music_animation"];
}

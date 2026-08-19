main()
{
	precache();
	precacheText();
	precacheFx();

	sr\sys\_env::initEnvs();
	sr\sys\_events::initEvents();
	sr\sys\_file::initFiles();
	sr\sys\_ftp::initFTP();
	sr\sys\_http::initHTTP();
    sr\sys\_mysql::initMySQL();
	sr\sys\_gpt::initGPT();
	sr\sys\_discord::initDiscord();
	sr\sys\_admins::initAdmins();
}

precache()
{
	level.assets = IfUndef(level.assets, []);
	level.texts = IfUndef(level.texts, []);
	level.gfx =  IfUndef(level.gfx, []);

	precacheItem("airstrike_mp");
	precacheItem("artillery_mp");
	precacheItem("c4_mp");
	precacheItem("claymore_mp");
	precacheItem("cobra_20mm_mp");
	precacheItem("cobra_FFAR_mp");
	precacheItem("dog_mp");
	precacheItem("flash_grenade_mp");
	precacheItem("fortnite_mp");
	precacheItem("frag_grenade_mp");
	precacheItem("frag_grenade_short_mp");
	precacheItem("hind_FFAR_mp");
	precacheItem("knife_mp");
	precacheItem("rpg_mp");
	precacheItem("saw_mp");
	precacheItem("smoke_grenade_mp");
	precacheItem("tomahawk_mp");

	precacheShader("black");
	precacheShader("hudstopwatch");
	precacheShader("killiconfalling");
	precacheShader("killiconheadshot");
	precacheShader("killiconmelee");
	precacheShader("killiconsuicide");
	precacheShader("score_icon");
	precacheShader("speedrunner_logo");
	precacheShader("sr_dice");
	precacheShader("sr_insert");
	precacheShader("sr_shop");
	precacheShader("sr_vip");
	precacheShader("stance_stand");
	precacheShader("time_hud");
	precacheShader("vip_gold");
	precacheShader("vip_status");
	precacheShader("white");

	precacheModel("axis");
	precacheModel("bc_militarytent_draped");
	precacheModel("body_mp_usmc_cqb");
	precacheModel("ch_crate64x64");
	precacheModel("ch_roadrock_06");
	precacheModel("ch_russian_table");
	precacheModel("chicken");
	precacheModel("german_sheperd_dog");
	precacheModel("mil_frame_charge");
	precacheModel("prop_flag_neutral");
	precacheModel("prop_flag_russian");
	precacheModel("tag_origin");
	precacheModel("viewmodel_hands_zombie");

	precacheStatusIcon("hud_status_connecting");
	precacheStatusIcon("hud_status_dead");
	precacheStatusIcon("vip_status");

	precacheShellShock("flashbang");

	precacheMenu("clientcmd");
}

precacheText()
{
	level.texts["empty"] = &"";
	level.texts["round_begins_in"] = &"SR_ROUND_BEGINS_IN";
	level.texts["waiting_for_players"] = &"SR_WAITING_FOR_PLAYERS";
	level.texts["jumpers_count"] = &"SR_ALIVE_JUMPERS";
	level.texts["call_freeround"] = &"SR_CALL_FREEROUND";
	level.texts["time"] = &"^2&&1";
	level.texts["ended_game"] = &"MP_HOST_ENDED_GAME";
	level.texts["endgame"] = &"MP_HOST_ENDGAME_RESPONSE";

	precacheString(level.texts["empty"]);
	precacheString(level.texts["round_begins_in"]);
	precacheString(level.texts["waiting_for_players"]);
	precacheString(level.texts["jumpers_count"]);
	precacheString(level.texts["call_freeround"]);
	precacheString(level.texts["time"]);
	precacheString(level.texts["ended_game"]);
	precacheString(level.texts["endgame"]);
}

precacheFx()
{
	level.gfx["lasershow"] = loadFx("speedrun/lasershow");
	level.gfx["endgame"] = loadFx("speedrun/endgame_fx");
	level.gfx["light_blink"] = loadFx("misc/light_c4_blink");
	level.gfx["endtrig_fx"] = loadFx("speedrun/endtrig_fx");
	level.gfx["endtrigcircle_fx"] = loadFx("speedrun/endtrigcircle_fx");
	level.gfx["secrettrig_fx"] = loadFx("speedrun/secrettrig_fx");
	level.gfx["yellow_fx"] = loadFx("speedrun/yellow_fx");
	level.gfx["red_fx"] = loadFx("speedrun/red_fx");
	level.gfx["purple_fx"] = loadFx("speedrun/purple_fx");
	level.gfx["orange_fx"] = loadFx("speedrun/orange_fx");
	level.gfx["green_fx"] = loadFx("speedrun/green_fx");
	level.gfx["cyan_fx"] = loadFx("speedrun/cyan_fx");
	level.gfx["secrettrigcircle_fx"] = loadFx("speedrun/secrettrigcircle_fx");
	level.gfx["wr_event"] = loadFx("speedrun/wr_fx");
	level.gfx["viptrail1"] = loadFx("speedrun/vip_trail1");
	level.gfx["viptrail2"] = loadFx("speedrun/vip_trail2");
	level.gfx["viptrail3"] = loadFx("speedrun/vip_trail3");
	level.gfx["viptrail4"] = loadFx("speedrun/vip_trail4");
	level.gfx["viptrail5"] = loadFx("speedrun/vip_trail5");
	level.gfx["startnstop"] = loadFx("speedrun/flare_startnstop");
	level.gfx["jetpack"] = loadFx("smoke/jetpack");
	level.gfx["meteor"] = loadFx("fire/tank_fire_engine");
	level.gfx["explosion"] = loadFx("explosions/grenadeExp_default");
	level.gfx["flame"] = loadFx("fire/tank_fire_engine");

	visionSetNaked(toLower(level.map), 0);
}

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
	sr\sys\_ids::initIds();
    sr\sys\_mysql::initMySQL();
    sr\sys\_curl::initCURL();
	sr\sys\_discord::initDiscord();
	sr\sys\_admins::initAdmins();
	sr\sys\_notifications::initNotifications();

	sr\game\_rank::initRank();
	sr\game\_cheat::main();
	sr\game\_demo::main();
	sr\game\_perks::initPerks();
	sr\game\_defrag::main();
	sr\game\_time::main();
	sr\game\_vote::initVote();
	sr\game\_poll::initPoll();
	sr\game\fx\_trail::main();
	sr\game\menus\_main::initMenus();
	sr\game\menus\_owner::main();
	sr\game\minigames\_main::initMinigames();
	sr\game\music\_main::initMusics();
	sr\game\weapons\_main::main();

	sr\commands\_admin::main();
	sr\commands\_debug::main();
	sr\commands\_graphics::main();
	sr\commands\_misc::main();
	sr\commands\_music::main();
	sr\commands\_player::main();
	sr\commands\_vote::main();
	sr\commands\_map::main();

	sr\player\_hide::main();
	sr\player\_insertion::main();
	sr\player\_settings::main();
	sr\player\fx\_spray::main();
	sr\player\fx\_shaders::initShaders();
	sr\player\modes\_main::initModes();
	sr\player\modes\_defrag::main();
	sr\player\modes\_noclip::main();
	sr\player\modes\_pickup::main();
	sr\player\modes\_portal::main();
	sr\player\modes\_practise::main();
	sr\player\modes\_debug::main();
	sr\player\huds\_cgaz::main();
	sr\player\huds\_crosshair::main();
	sr\player\huds\_fps::main();
	sr\player\huds\_keys::main();
	sr\player\huds\_velocity::main();
	sr\player\huds\_viewkick::main();
	sr\player\huds\_voice::main();
}

precache()
{
	level.assets = [];
	level.texts = [];
	level.gfx = [];

	precacheItem("claymore_mp");
	precacheItem("c4_mp");
	precacheItem("rpg_mp");
	precacheItem("frag_grenade_short_mp");
	precacheItem("frag_grenade_mp");
	precacheItem("smoke_grenade_mp");
	precacheItem("flash_grenade_mp");

	precacheShader("black");
	precacheShader("white");
	precacheShader("killiconsuicide");
	precacheShader("killiconmelee");
	precacheShader("killiconheadshot");
	precacheShader("killiconfalling");
	precacheShader("stance_stand");
	precacheShader("hudstopwatch");
	precacheShader("score_icon");

	precacheModel("tag_origin");
	precacheModel("viewmodel_hands_zombie");
	precacheModel("body_mp_usmc_cqb");
}

precacheText()
{
	level.texts["empty"] 				= &"";
	level.texts["round_begins_in"] 		= &"SR_ROUND_BEGINS_IN";
	level.texts["waiting_for_players"] 	= &"SR_WAITING_FOR_PLAYERS";
	level.texts["jumpers_count"] 		= &"SR_ALIVE_JUMPERS";
	level.texts["call_freeround"] 		= &"SR_CALL_FREEROUND";
	level.texts["time"] 				= &"^2&&1";
	level.texts["ended_game"]			= &"MP_HOST_ENDED_GAME";
	level.texts["endgame"]				= &"MP_HOST_ENDGAME_RESPONSE";

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
	level.gfx["pickup"]					= loadFx("misc/ui_pickup_available");
	level.gfx["lasershow"] 				= loadFx("deathrun/lasershow");
	level.gfx["endgame"] 				= loadFx("deathrun/endgame_fx");
	level.gfx["light_blink"] 			= loadFx("misc/light_c4_blink");
	level.gfx["endtrig_fx"] 				= loadFx("deathrun/endtrig_fx");
	level.gfx["endtrigcircle_fx"] 		= loadFx("deathrun/endtrigcircle_fx");
	level.gfx["secrettrig_fx"] 			= loadFx("deathrun/secrettrig_fx");
	level.gfx["yellow_fx"] 				= loadFx("deathrun/yellow_fx");
	level.gfx["red_fx"] 					= loadFx("deathrun/red_fx");
	level.gfx["purple_fx"] 				= loadFx("deathrun/purple_fx");
	level.gfx["orange_fx"] 				= loadFx("deathrun/orange_fx");
	level.gfx["green_fx"] 				= loadFx("deathrun/green_fx");
	level.gfx["cyan_fx"] 				= loadFx("deathrun/cyan_fx");
	level.gfx["secrettrigcircle_fx"] 	= loadFx("deathrun/secrettrigcircle_fx");
	level.gfx["wr_event"] 				= loadFx("deathrun/wr_fx");
	level.gfx["viptrail1"] 				= loadFx("deathrun/vip_trail1");
	level.gfx["viptrail2"] 				= loadFx("deathrun/vip_trail2");
	level.gfx["viptrail3"] 				= loadFx("deathrun/vip_trail3");
	level.gfx["viptrail4"] 				= loadFx("deathrun/vip_trail4");
	level.gfx["viptrail5"] 				= loadFx("deathrun/vip_trail5");
	level.gfx["startnstop"] 				= loadFx("deathrun/flare_startnstop");
	level.gfx["jetpack"] 				= loadFx("smoke/jetpack");
	level.gfx["meteor"] 					= loadFx("fire/tank_fire_engine");
	level.gfx["explosion"] 				= loadFx("explosions/grenadeExp_default");
	level.gfx["flame"] 					= loadFx("fire/tank_fire_engine");

	visionSetNaked(toLower(level.map), 0);
}
